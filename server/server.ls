{map} = require 'prelude-ls'
hapi = require "hapi"
zmq = require 'zmq'

server = new hapi.Server!
server.connection {port: 4000}
io = require 'socket.io' <| server.listener
sub-sock = zmq.socket 'sub'
pub-sock = zmq.socket 'pub'

pub-sock.connect 'tcp://127.0.0.1:5012'

set-interval (->
  console.log "interval!"
  msg = do
    sender: [\naber]
    cls: \PingMessage
    text: \nabernaber
    debug: []

  pub-sock.send JSON.stringify msg

  ),
  2000


# zmq subscribe
sub-sock.connect 'tcp://127.0.0.1:5013'
sub-sock.subscribe ''  # get all messages

process.on 'SIGINT', ->
  sub-sock.close!
  console.log 'subscriber closed!'


# Forward socket.io messages to and from zeromq messages
io.on 'connection', (socket) ->
  socket.on "aktos-message", (message) ->
    console.log "aktos-message from browser: ",
      message,
      'broadcasting all others'

    # broadcast all web clients
    socket.broadcast.emit 'aktos-message', message
    # send to client itself, since same instance may
    # have more than one copy of the same instance
    socket.emit 'aktos-message', message
    # send to other processes via zeromq
    pub-sock.send message

  sub-sock.on 'message', (message) ->
    console.log 'Forwarding zmq message to socket.io: ', message.to-string!
    socket.broadcast.emit 'aktos-message', message.to-string!


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
