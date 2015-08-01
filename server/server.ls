{map} = require 'prelude-ls'
hapi = require "hapi" 
server = hapi.create-server 4000 
io = require 'socket.io' <| server.listener

# Handle socket.io connections
io.on 'connection', (socket) -> 
  socket.on "tweet", (tweet) -> 
    console.log "tweet from browser",
      tweet, 
      'broadcasting all others'
    socket.broadcast.emit 'tweet', tweet
    socket.emit 'tweet', tweet
    

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
    



#a = require './static/weblib'
#a.test!
 
server.start !->
  console.log "Server running at:", server.info.uri
