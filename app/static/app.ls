require! {
  '../modules/prelude': {
    flatten,
    initial,
    drop,
    join,
    concat,
    tail,
    head,
    map,
    zip,
    split,
    union,
    last
  }
}


require! {
  '../modules/aktos-dcs': {
    envelp,
    get-msg-body,
    Actor,
    ProxyActor,
    RactivePartial,
    get-ractive-var, 
    set-ractive-var, 
    SwitchActor,
    RactiveApp, 
  }
}
  
require '../partials/ractive-partials'
require '../partials/test-widget'
require '../partials/textbox'
require '../partials/status-led'
require '../partials/push-button'
require '../partials/slider'
require '../partials/analog-display'
require '../partials/line-graph'

# aktos widget library

# ---------------------------------------------------
# END OF LIBRARY FUNCTIONS
# ---------------------------------------------------


set-switch-actors = !->
  $ '.switch-actor' .each !->
    elem = $ this
    pin-name = get-ractive-var elem, 'pin_name'
    actor = SwitchActor pin-name
    actor.set-node elem
    elem.data \actor, actor


      
jquery-mobile-specific = -> 
  set-project-buttons-height = (height) -> 
    $ \.project-buttons .each -> 
      $ this .height height

  make-windows-size-work = ->
    window-width = $ window .width!
    console.log "window width: #window-width"
    set-project-buttons-height window-width/3.1

  $ window .resize -> 
    #make-windows-size-work!
  
  #make-windows-size-work!
  
  
# Set Ractive.DEBUG to false when minified:
Ractive.DEBUG = /unminified/.test !->
  /*unminified*/

app = new Ractive do
  el: 'container'
  template: '#app'

RactiveApp!set app

## debug
#console.log 'socket.io path: ', addr_port,  socketio-path
#console.log "socket.io socket: ", socket

# Create the actor which will connect to the server
ProxyActor!



app.on 'complete', !->
  #$ '#debug' .append '<p>app.complete started...</p>'
  #console.log "ractive completed, post processing other widgets..."

  # create actors for every widget
  set-switch-actors!

  $ document .ready ->
    console.log "document is ready..."
    jquery-mobile-specific!
    RactivePartial! .init-for-document-ready!
  
  #console.log "window.location: ", window.location
  if not window.location.hash
    window.location = '#home-page'
  #console.log "app.complete ended..."
  
  RactivePartial! .init!
  
  console.log "ractive app completed..."
    
  