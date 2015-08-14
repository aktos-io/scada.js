{map, filter, tail} = require 'prelude-ls'
Hapi = require "hapi"
zmq = require 'zmq'
#msgpack = require 'msgpack-js'

server = new Hapi.Server!
server.connection port: 4000
io = require 'socket.io' .listen server.listener
sub-sock = zmq.socket 'sub'
pub-sock = zmq.socket 'pub'

# connection ip
broker-ip = '127.0.0.1'
#broker-ip = '10.0.10.4'

# make zmq settings BEFORE connect/bind:
pub-sock.setsockopt zmq.ZMQ_SNDHWM, 1
pub-sock.setsockopt zmq.ZMQ_LINGER, 0

sub-sock.subscribe ''  # subscribe all messages

# make zmq connections
pub-sock.connect 'tcp://' + broker-ip + ':5012'
sub-sock.connect 'tcp://' + broker-ip + ':5013'

process.on 'SIGINT', ->
  sub-sock.close!
  pub-sock.close!

  console.log 'Received SIGINT, zmq sockets are closed...'
  process.exit 0


pack = (msg)->
  #console.log "pack: ", msg
  #msgpack.encode(msg)
  JSON.stringify msg

unpack = (message) ->
  #msgpack.decode(message)
  JSON.parse message

server-id = "server-ls--give-a-unique-id-here!"
message-history = []  # msg_id, timestamp

aktos-dcs-filter = (msg) ->
  if server-id in msg.sender
    # drop short circuit message
    console.log "dropping short circuit message", msg
    return null

  if 'ProxyActorMessage' of msg.payload
    # drop control message
    console.log "dropping control message", msg
    return null

  if msg.msg_id in [i.0 for i in message-history]
    # drop duplicate message
    console.log "dropping duplicate message: ", msg.msg_id
    return null


  message-history ++= [[msg.msg_id, msg.timestamp]]
  #console.log "message history: ", message-history

  return msg

cleanup-msg-history = ->
  now = Date.now! / 1000 or 0
  timeout = 10_s
  #console.log "msg history before: ", message-history.length
  message-history := [r for r in message-history when r.1 > now - timeout]
  #console.log "msg history after: ", message-history.length

set-interval cleanup-msg-history, 10000_ms

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
  #console.log "aktos message from network ", message.to-string!
  try
    msg = unpack message
    msg = aktos-dcs-filter msg
    if msg
      msg.sender ++= [server-id]
      console.log "forwarding msg to clients, msg_id: ", msg.msg_id
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
