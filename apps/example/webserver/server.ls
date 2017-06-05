require! <[ fs express path url http-proxy serve-index ]>
argv = require 'yargs' .argv




# Select development or production folder to serve
production-public = "#{__dirname}/../../../__public__"
development-public = "#{__dirname}/../../../build"

if argv.target is \production
    console.log "----------------------------------------"
    console.log "        PRODUCTION (__public__)         "
    console.log "----------------------------------------"
    console.log "Found production public, using this one."
    pub-dir = production-public
else
    console.log "----------------------------------------"
    console.log "        DEVELOPMENT (build/public)      "
    console.log "----------------------------------------"
    console.log "production public not found, using development public..."
    pub-dir = development-public


app = express!
proxy = require 'express-http-proxy'
http = require \http .Server app
# TODO: io = (require "engine.io") http


app.get "/", (req, res) ->
    console.log "#{argv.target}: req: ", req.path
    res.send-file path.resolve "#{pub-dir}/aktos.html"

app.use (req, res, next) ->
    filename = path.basename req.url
    extension = path.extname filename
    #console.log "File: #{filename} was requested."
    next!

i = ''
console.log "serving static folder: /#{i}"
app.use "/#{i}", express.static path.resolve "#{pub-dir}/#{i}"

# serve history
app.use '/history', serve-index "#{production-public}/history"

/*
app.get '*', (req, res) ->
    console.log "#{argv.target}: req: ", req.path
    res.send-file path.resolve "#{pub-dir}/demeter.html"
*/

server-port = argv.port
try
    server-port % 1 is 0
catch
    default-port = 4001
    console.log "...using default port: #{default-port}"
    server-port = default-port

http.listen server-port, ->
  console.log "listening on *:#{server-port}"
