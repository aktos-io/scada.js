hapi = require "hapi"
http-proxy = require 'http-proxy'
server = new hapi.Server!
    ..connection do
      port: 4001
      routes:
        cors: true
    ..register (require 'h2o2'), ->
    ..register (require 'inert'), ->
path = require \path

public-dir = path.join __dirname, "../../build/public"
console.log "Public Directory: #{public-dir}"

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
    file: "#{public-dir}/index.html"

server.route do
  path: "/app/{f*}"
  method: "GET"
  handler:
    directory:
      path: "#{public-dir}/pages"

server.route do
  path: "/js/{f*}"
  method: "GET"
  handler:
    directory:
      path: "#{public-dir}/js"

server.route do
  path: "/css/{f*}"
  method: "GET"
  handler:
    directory:
      path: "#{public-dir}/css"

server.route do
  path: "/fonts/{f*}"
  method: "GET"
  handler:
    directory:
      path: "#{public-dir}/fonts"

server.start !->
  console.log "Server started at: ", server.info.uri
