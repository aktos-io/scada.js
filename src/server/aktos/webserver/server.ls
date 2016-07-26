require! <[ fs express path ]>

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
http = require \http .Server app
# TODO: io = (require "engine.io") http


app.get "/", (req, res) ->
  res.send-file path.resolve "#{pub-dir}/demeter.html"

i = ''
console.log "serving static folder: /#{i}"
app.use "/#{i}", express.static path.resolve "#{pub-dir}/#{i}"

http.listen 4001 ->
  console.log "listening on *:4001"
