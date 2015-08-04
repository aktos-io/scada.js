{map} = require 'prelude-ls'
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


# Forward socket.io messages to and from zeromq messages
io.on 'connection', (socket) ->
  # for every connected socket.io client, do the following:
  console.log "new client connected, starting its forwarder..."

  socket.on "aktos-message", (message) ->
    #console.log "aktos-message from browser: ", message

    # broadcast all web clients
    socket.broadcast.emit 'aktos-message', message

    # send to other processes via zeromq
    pub-sock.send message

  sub-sock.on 'message', (message) ->
    message = message.to-string!
    socket.broadcast.emit 'aktos-message', message


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
