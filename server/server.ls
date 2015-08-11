{map, filter, tail} = require 'prelude-ls'
Hapi = require "hapi"
zmq = require 'zmq'
msgpack = require 'msgpack-js'

server = new Hapi.Server!
server.connection port: 4000
io = require 'socket.io' .listen server.listener
sub-sock = zmq.socket 'sub'
pub-sock = zmq.socket 'pub'

# connect to default broker
#pub-sock.connect 'tcp://127.0.0.1:5012'
#sub-sock.connect 'tcp://127.0.0.1:5013'
pub-sock.connect 'tcp://10.0.10.4:5012'
sub-sock.connect 'tcp://10.0.10.4:5013'

pub-sock['lingerPeriod'] = 0
pub-sock['highWaterMark'] = 2
sub-sock.subscribe ''  # subscribe all messages

process.on 'SIGINT', ->
  sub-sock.close!
  pub-sock.close!
  sub-sock.term!
  pub-sock.term!

  console.log 'Received SIGINT, zmq sockets are closed...'
  process.exit 0

pack = (msg)->
  #console.log "pack: ", msg
  msgpack.encode(msg)

unpack = (message) ->
  msgpack.decode(message)


test = {'naber': 'iyidir'}
console.log "msgpack: ", unpack pack test

server-id = "server-ls--give-a-unique-id-here!"
message-history = []  # msg_id, timestamp

aktos-dcs-filter = (msg) ->
  if server-id in msg.sender
    # drop short circuit message
    return null

  if msg.cls == 'ProxyActorMessage'
    # drop control message
    return null

  if msg.msg_id in [i.0 for i in message-history]
    # drop duplicate message
    #console.log "dropping duplicate message: ", msg.msg_id
    return null

  now = Date.now! / 1000 or 0
  timeout = 10_s
  treshold = now - timeout

  message-history ++= [[msg.msg_id, msg.timestamp]]
  #console.log "message history: ", message-history

  if message-history.0
    if message-history.0.1 < treshold
      #console.log "deleting ",
      #  now - message-history.0.1," secs old message"
      message-history := tail message-history
  return msg

# Forward socket.io messages to and from zeromq messages
io.on 'connection', (socket) !->
  # for every connected socket.io client, do the following:
  console.log "new client connected, starting its forwarder..."

  socket.on "aktos-message", (msg) !->
    #console.log "aktos-message from browser: ", msg

    # append server-id to message.sender list
    msg.sender ++= [server-id]

    # broadcast all web clients excluding sender
    socket.broadcast.emit 'aktos-message', msg

    # send to other processes via zeromq
    pub-sock.send pack msg

sub-sock.on 'message', (message) !->
  #console.log "aktos message from network "
  #message = message.to-string!
  try
    msg = unpack message
    #console.log "aktos message from network: ", msg

    msg = aktos-dcs-filter msg
    if msg
      msg.sender ++= [server-id]
      #console.log "forwarding to client: ", msg.sender
      io.sockets.emit 'aktos-message', msg


server.route do
  method: 'GET'
  path: '/'
  handler:
    file: './public/index.html'

server.route do
  method: 'GET'
  path: '/{filename*}'
  handler:
    directory:
      path: 'public'
      listing: 'true'
      index: ['index.html']

#a = require './app/lib/weblib.ls'
#a.test!

server.start !->
  console.log "Server running at:", server.info.uri
