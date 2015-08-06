{map, filter, tail} = require 'prelude-ls'
hapi = require "hapi"
zmq = require 'zmq'

server = new hapi.Server!
server.connection {port: 4000}
io = require 'socket.io' <| server.listener
sub-sock = zmq.socket 'sub'
pub-sock = zmq.socket 'pub'

# connect to default broker
pub-sock.connect 'tcp://127.0.0.1:5012'
sub-sock.connect 'tcp://127.0.0.1:5013'
sub-sock.subscribe ''  # subscribe all messages

process.on 'SIGINT', ->
  sub-sock.close!
  pub-sock.close!
  console.log 'Received SIGINT, zmq sockets are closed...'
  process.exit 0 

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
io.on 'connection', (socket) ->
  # for every connected socket.io client, do the following:
  console.log "new client connected, starting its forwarder..."

  socket.on "aktos-message", (msg) ->
    #console.log "aktos-message from browser: ", msg
    # append server-id to message.sender list
    msg.sender ++= [server-id]

    # broadcast all web clients
    socket.broadcast.emit 'aktos-message', msg

    # send to other processes via zeromq
    pub-sock.send JSON.stringify msg

  sub-sock.on 'message', (message) ->
    message = message.to-string!
    msg = JSON.parse message

    msg = aktos-dcs-filter msg
    if msg
      msg.sender ++= [server-id]
      #console.log "forwarding to client: ", msg.sender
      socket.broadcast.emit 'aktos-message', msg
      socket.emit 'aktos-message', msg

server.route do
  method: 'GET'
  path: '/'
  handler:
    file: './public/index.html'

server.route do
  method: 'GET'
  path: '/{filename*}'
  handler:
    file: (request) ->
      return './public/' + request.params.filename

server.route do
  method: 'GET'
  path: '/static/{filename*}'
  handler:
    file: (request) ->
      return './public/' + request.params.filename

#a = require './app/lib/weblib.ls'
#a.test!

server.start !->
  console.log "Server running at:", server.info.uri
