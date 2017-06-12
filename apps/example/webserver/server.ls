# -----------------------------------------------------------------------------
# Webserver
# -----------------------------------------------------------------------------
require! \fs
require! \path
require! \express
argv = require 'yargs' .argv

pub-dir = development-public = "#{__dirname}/../../../build"
app = express!
http = require \http .Server app

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

# -----------------------------------------------------------------------------
# DCS codes
# -----------------------------------------------------------------------------
require! 'aktos-dcs/src/socketio-server': {SocketIOServer}
require! 'aktos-dcs/src/broker': {Broker}

# create socket.io server
io = (require "socket.io") http
new SocketIOServer io, 'socketio server'

# start a broker to share messages over dcs network
new Broker!

# -----------------------------------------------------------------------------
# Test codes
# -----------------------------------------------------------------------------
require! './monitor': {Monitor}
new Monitor!
