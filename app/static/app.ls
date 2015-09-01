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
  
require '../partials/test-widget'
require '../partials/textbox'
require '../partials/status-led'
require '../partials/push-button'
require '../partials/slider'
require '../partials/analog-display'

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
  
  

make-line-graph-widget = -> 

  $ \.line-graph .each ->
    elem = $ this 
    pin-name = get-ractive-var  elem, \pin_name 
    actor = SwitchActor pin-name
    
    
    #console.log "this is graph widget: ", elem, actor.actor-name
    
    /*    
    graph-data = -> 
      return do
        * label: 'test'
          data: get-graph-data!
          color: 'white'
        * label: 'test2'
          data: get-graph-data!
          color: 'red'

    */
    data = []
    total-points = 300 
    
    y-max = 1000
    y-min = 0 
    
    push-random-data = -> 
      if data.length > 0
        data := tail data 
        
      while data.length < total-points
        
        prev = if data.length > 0 then last data else y-max / 2

        y = prev + Math.random! * 10  - 5
        y = y-min if y < y-min
        y = y-max if y > y-max 
        
        data.push y 
        
    get-graph-data = -> 
      return [zip [0 to total-points] data]
      
    #console.log "random data: ", get-random-data! 

    push-graph-data = (new-point) ->
      totalPoints = 300
      if data.length > 0 then
        data := tail data
      while data.length < total-points 
        data.push new-point

    
    update-interval = 30 
    
    push-random-data!
    plot = $.plot '#placeholder', get-graph-data!, do 
      series: 
        shadow-size: 0 
      yaxis: 
        min: y-min
        max: y-max
      xaxis:
        show: false
            
    
    refresh = -> 
      plot.set-data get-graph-data!
      plot.draw!
    
    
    update = -> 
      #push-random-data!
      push-graph-data last data
      plot.set-data get-graph-data!
      plot.resize!
      plot.setup-grid!
      plot.draw!
      set-timeout update, update-interval 
      
    update!

    actor.add-callback (msg) -> 
      console.log "line-graph got new value: #{msg.val}"
      push-graph-data msg.val
      #refresh!

make-graph-widgets = -> 
  make-line-graph-widget!

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
  
  # graph widgets
  make-graph-widgets!
  
  #$ \#debug .append '<p>app.complete ended...</p>'
  
  #console.log "window.location: ", window.location
  if not window.location.hash
    window.location = '#home-page'
  #console.log "app.complete ended..."
  
  RactivePartial! .init!
  
  console.log "ractive app completed..."
    
  #console.log "app.get: ", app.get ($ '#my-textbox' .get 0)
  #console.log "get node info: ", Ractive.get-node-info ($ '#aaa' .get 0)
  
#shortid = require 'modules/shortid/index'
#console.log "shortid: ", shortid
  