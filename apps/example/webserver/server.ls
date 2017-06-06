require! <[ fs express path url http-proxy serve-index ]>
require! \shortid
require! \express
require! 'aktos-dcs/core': {envelp, get-msg-body}
require! 'aea': {pack, unpack}
argv = require 'yargs' .argv


pub-dir = development-public = "#{__dirname}/../../../build"

app = express!
http = require \http .Server app
io = (require "socket.io") http

app.get "/", (req, res) ->
    console.log "req: ", req.path
    res.send-file path.resolve "#{pub-dir}/example/showcase/index.html"

app.use (req, res, next) ->
    filename = path.basename req.url
    extension = path.extname filename
    #console.log "File: #{filename} was requested."
    next!

console.log "serving static folder: /"
app.use "/", express.static path.resolve "#{pub-dir}/"

server-port = argv.port
try
    server-port % 1 is 0
catch
    default-port = 4001
    console.log "...using default port: #{default-port}"
    server-port = default-port

http.listen server-port, ->
  console.log "listening on *:#{server-port}"

process.on 'SIGINT', ->
  console.log 'Received SIGINT, cleaning up...'
  process.exit 0

server-id = shortid.generate!
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
    console.log "aktos-message from browser: ", msg

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
      #pub-sock.send pack msg


/*
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
*/
