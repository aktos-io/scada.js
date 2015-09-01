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

# basic widgets 
set-switch-buttons = !->
  $ '.switch-button' .each !->
    elem = $ this
    actor = elem.data \actor

    # make it work without toggle-switch
    # visualisation
    elem.change ->
      actor.gui-event this.checked
    actor.add-callback (msg) ->
      elem.prop 'checked', msg.val

set-push-buttons = ->
  #
  # TODO: tapping works as doubleclick (two press and release)
  #       fix this.
  #
  $ '.push-button' .each ->
    elem = $ this
    actor = elem.data \actor

    # desktop support
    elem.on 'mousedown' ->
      actor.gui-event on
      elem.on 'mouseleave', ->
        actor.gui-event off
    elem.on 'mouseup' ->
      actor.gui-event off
      elem.off 'mouseleave'

    # touch support
    elem.on 'touchstart' (e) ->
      actor.gui-event on
      elem.touchleave ->
        actor.gui-event off
      e.stop-propagation!
    elem.on 'touchend' (e) ->
      actor.gui-event off

    actor.add-callback (msg) ->
      #console.log "push button got message: ", msg
      if msg.val
        elem.add-class 'button-active-state'
      else
        elem.remove-class 'button-active-state'

set-status-leds = ->
  console.log "really??"
  
set-analog-displays = ->
  $ \.analog-display .each ->
    elem = $ this
    channel-name = get-ractive-var  elem, 'pin_name'
    #console.log "this is channel name: ", channel-name
    actor = SwitchActor channel-name
    actor.add-callback (msg) ->
      set-ractive-var  elem, 'val', msg.val

make-basic-widgets = -> 
  set-switch-buttons!
  set-push-buttons!
  set-status-leds!
  set-analog-displays!

# create jq mobile widgets 
make-jq-mobile-widgets = !->
  #console.log "mobile connections are being done..."
  $ document .ready ->
    #console.log "document ready!"

    # jq-flipswitch-v2
    make-jq-flipswitch-v2 = -> 
      $ \.switch-button .each ->
        #console.log "switch-button created"
        elem = $ this
        actor = elem.data \actor

        send-gui-event = (event) -> 
          #console.log "jq-flipswitch-2 sending msg: ", elem.val!        
          actor.gui-event (elem.val! == \on)

        elem.on \change, send-gui-event
        
        actor.add-callback (msg) ->
          #console.log "switch-button got message", msg
          elem.unbind \change
          
          if msg.val
            elem.val \on .slider \refresh
          else
            elem.val \off .slider \refresh
          
          elem.bind \change, send-gui-event 
          
    make-jq-flipswitch-v2!
        
    # jq-push-button
    make-jq-push-button = -> 
      set-push-buttons!  # inherit basic button settings
      $ \.push-button .each ->
        #console.log "found push-button!"
        elem = $ this
        actor = elem.data \actor
        
        actor.add-callback (msg) ->
          #console.log "jq-push-button got message: ", msg.val
          if msg.val
            elem.add-class 'ui-btn-active'
          else
            elem.remove-class 'ui-btn-active'
          
        # while long pressing on touch devices, 
        # no "select text" dialog should be fired: 
        elem.disable-selection!
        elem.onselectstart = ->
          false
        elem.unselectable = "on"
        elem.css '-moz-user-select', 'none'
        elem.css '-webkit-user-select', 'none'
    
    make-jq-push-button!

    # slider
    make-slider = !->
      $ '.slider' .each !->
        elem = $ this 
        actor = elem.data \actor
        
        #console.log "this slider actor found: ", actor 
        #debugger 
        
        slider = elem.find \.jq-slider 
        slider.slider!
        #console.log "slider created!", slider
        
        curr_val = slider.attr \value
        slider.val curr_val .slider \refresh 
        #console.log "current value: ", curr_val
        
        input = elem.find \.jq-slider-input
        
        input.on \change -> 
          val = get-ractive-var  elem, \val
          actor.gui-event val
          
        
        slider.on \change ->
          #console.log "slider val: ", slider.val!
          actor.gui-event slider.val!
          
        actor.add-callback (msg)->
          #console.log "slider changed: ", msg.val 
          slider.val msg.val .slider \refresh
          set-ractive-var  elem, \val, msg.val 
        
        
    make-slider!
    
    # inherit status leds
    set-status-leds!
    
    # inherit analog displays
    set-analog-displays!


make-jq-page-settings = ->
  navnext = (page) ->
    $.mobile.navigate page

  navprev = (page) ->
    $.mobile.navigate page

  $ window .on \swipe, (event) ->
    navnext \#foo
    #$.mobile.change-page \#foo

make-toggle-switch-visualisation = ->
  $ \.toggle-switch .each !->
    elem = $ this
    actor = elem.data \actor

    s = new ToggleSwitch elem.get 0, 'on', 'off'
    actor.add-callback (msg) ->
      # prevent switch callback call on
      # external events. only change visual status.
      tmp = s.f-callback
      s.f-callback = null
      if msg.val
        s.on!
      else
        s.off!
      s.f-callback = tmp
      tmp = null

    s.add-listener (state) !->
      actor.send-event state
      
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

  # create basic widgets
  #make-basic-widgets!

  $ document .ready ->
    # create jquery mobile widgets 
    console.log "document is ready..."
    make-jq-mobile-widgets!
    jquery-mobile-specific!
    # set jquery mobile page behaviour
    #make-jq-page-settings!
  
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
  