hapi = require "hapi"
http-proxy = require 'http-proxy'
server = new hapi.Server!
server.connection do
  port: 4000
  routes:
    cors: true

server.register (require 'h2o2'), ->
server.register (require 'inert'), ->

server.route do
  method: '*'
  path: '/kds/{f*}'
  handler:
    proxy:
      map-uri: (request, callback) ->
        resourceUri = request.url.path.replace('/kds/', '/')
        url = "http://192.168.1.15/DemeterKds/api/rfm/ScoresVersion?rawMaterialCode=19&VersionNumber=635973759505058264"
        console.log 'url: ', url
        callback(null,url);
      pass-through: true
      xforward: true

server.route do
  path: "/"
  method: "GET"
  handler:
    file: "./public/index.html"

server.route do 
  path: "/app/{f*}"
  method: "GET"
  handler:
    directory:
      path: "./public/app"

server.route do
  path: "/scripts/{f*}"
  method: "GET"
  handler:
    directory:
      path: "./public/scripts"

server.start !->
  console.log "Server started at: ", server.info.uri
