require! <[ fs express path url ]>
require! 'http-proxy'


# Select development or production folder to serve
production-public = "#{__dirname}/../../../__public__"
development-public = "#{__dirname}/../../../build/public"
try
    fs.accessSync production-public
    console.log "----------------------------------------"
    console.log "        PRODUCTION (__public__)         "
    console.log "----------------------------------------"
    console.log "Found production public, using this one."
    pub-dir = production-public
catch
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
  res.send-file path.resolve "#{pub-dir}/showcase.html"

i = ''
console.log "serving static folder: /#{i}"
app.use "/#{i}", express.static path.resolve "#{pub-dir}/#{i}"

app.use '/_db', proxy 'http://127.0.0.1:5984'

server-port = 4002
http.listen server-port, ->
  console.log "listening on *:#{server-port}"
