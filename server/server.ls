{map, filter, tail} = require 'prelude-ls'

zmq = require 'zmq'
short-id = require \shortid

express = require \express
app = express!
http = require \http .Server app
io = (require "socket.io") http

#https://gist.github.com/dbainbridge/2424055#file-app-js-L13
pub-dir = __dirname + "/public"

static-folders =
  * \javascripts
  * \images
  * \img
  * \stylesheets
  * \fonts
  * \projects

for i in static-folders
  console.log "serving static folder: #{i}..."
  app.use "/#{i}", express.static "#{pub-dir}/#{i}"

app.get '/', (req, res) ->
  res.send-file "#{pub-dir}/index.html"

http.listen 4000 ->
  console.log "listening on *:4000"


#msgpack = require 'msgpack-js'
require! {
  './modules/aktos-dcs': {
    envelp,
    get-msg-body,
  }
}

if (parse-int zmq.version.0) < 4
  console.log "ERROR: "
  console.log "ERROR: "
  console.log "ERROR: libzmq version can not be lower than 4.x"
  console.log "ERROR: current version is: ", zmq.version
  console.log "ERROR: Exiting... "
  console.log "ERROR: "
  console.log "ERROR: "
  process.exit 1


#server.register (require 'h2o2'), ->
#server.register (require 'inert'), ->


sub-sock = zmq.socket 'sub'
pub-sock = zmq.socket 'pub'

# connection ip
broker-ip = '127.0.0.1'
#broker-ip = '10.0.10.176'

# make zmq settings BEFORE connect/bind:
pub-sock.setsockopt zmq.ZMQ_SNDHWM, 0  # this change is for issue #20
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

server-id = short-id.generate!
console.log "server is created with following id: #server-id"

message-history = []  # msg_id, timestamp

aktos-dcs-filter = (msg) ->
  if server-id in msg.sender
    # drop short circuit message
    console.log "dropping short circuit message", msg.payload
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


"""
mjpeg-camera = require \mjpeg-camera
camera = new mjpeg-camera do
  name: 'backdoor'
  url: 'http://localhost:8080/?action=stream'

camera.on \data, (frame) ->
  io.emit \frame, frame.data.to-string \base64

try
  camera.start!
catch
  console.log "mjpeg-camera can not be started..."
"""

user-db =
  * id: 1
    username: 'ceremcem'
    name: 'Cerem Cem ASLAN'
    secret: 'cca12345'
  * id: 2
    username: 'mesut'
    name: 'Mesut EVİN'
    secret: 'me12345'
  * id: 3
    username: 'tugrul'
    name: 'Tuğrul KUKUL'
    secret: 'tk12345'

handle-auth-message = (msg, socket) ->
  msg-body = get-msg-body msg
  console.log "server got control message: ", get-msg-body msg

  client-secret = msg-body.client_secret

  client-data = [user for user in user-db when client-secret == user.secret]

  client-data = if client-data.0 then
    client-data.0
  else
    name: "Misafir"

  console.log 'client data is: ', client-data

  token-msg = AuthMessage:
    token: 'this token is signed by server for this specific client'
    client_data: client-data

  console.log "sending token-msg: ", token-msg

  token-msg = envelp token-msg, 0
  token-msg.sender ++= [server-id]
  socket.emit 'aktos-message', token-msg


connected-user-count = 0

handle_UpdateIoMessage = (msg, socket) ->
  conn-msg = IoMessage:
    pin_name: 'online-users'
    val: connected-user-count
  conn-msg = envelp conn-msg, 1230
  conn-msg.sender ++= [server-id]
  io.sockets.emit 'aktos-message', conn-msg
  console.log "Notifying total user count: #{connected-user-count}", conn-msg


# Forward socket.io messages to and from zeromq messages
io.on 'connection', (socket) !->
  # for every connected socket.io client, do the following:
  console.log "new client connected, starting its forwarder..."
  console.log "+--> Connected to server with id: ", socket.id

  # track online users
  connected-user-count := connected-user-count + 1
  console.log "Total online user count: #{connected-user-count}"

  socket.on \disconnect, ->
    connected-user-count := connected-user-count - 1

    console.log "Total online user count: #{connected-user-count}"
    handle_UpdateIoMessage {}, socket


  socket.on "aktos-message", (msg) !->
    #console.log "aktos-message from browser: ", msg

    if \AuthMessage of msg.payload
      handle-auth-message msg, socket

    else
      if \UpdateIoMessage of msg.payload
        handle_UpdateIoMessage msg, socket

      # append server-id to message.sender list
      msg.sender ++= [server-id]

      # broadcast all web clients excluding sender
      socket.broadcast.emit 'aktos-message', msg

      # send to other processes via zeromq
      pub-sock.send pack msg



sub-sock.on 'message', (message) !->
  #console.log "aktos message from network ", message.to-string![\msg_id]
  try
    msg = unpack message
    #console.log "zeromq sub received message: ", msg.msg_id
    msg = aktos-dcs-filter msg
    if msg
      msg.sender ++= [server-id]
      #console.log "forwarding msg to clients, msg_id: ", msg.msg_id
      io.sockets.emit 'aktos-message', msg
