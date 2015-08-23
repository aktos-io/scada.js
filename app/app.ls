
require! {
  './prelude': {
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


# -----------------------------------------------------
# aktos-dcs livescript
# -----------------------------------------------------
envelp = (msg, msg-id) ->
  msg-raw = do
    sender: []
    timestamp: Date.now! / 1000
    msg_id: msg-id  # {{.actor_id}}.{{serial}}
    payload: msg
  return msg-raw

get-msg-body = (msg) ->
  subject = [subj for subj of msg.payload][0]
  #console.log "subject, ", subject
  return msg.payload[subject]



class ActorBase
  ~>
    @actor-id = uuid4!

  receive: (msg) ->
    #console.log @name, " received: ", msg.text

  recv: (msg) ->
    @receive msg
    try
      subjects = [subj for subj of msg.payload]
      for subject in subjects
        this['handle_' + subject] msg
    catch
      #console.log "problem in handler: ", e



# make a singleton
class ActorManager
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass extends ActorBase
    ~>
      super ...
      @actor-list = []
      #console.log "Manager created with id:", @actor-id

    register: (actor) ->
      @actor-list = @actor-list ++ [actor]

    inbox-put: (msg) ->
      msg.sender ++= [@actor-id]
      for actor in @actor-list
        if actor.actor-id not in msg.sender
          #console.log "forwarding msg: ", msg
          actor.recv msg


class Actor extends ActorBase
  (name) ~>
    super ...
    @mgr = ActorManager!
    @mgr.register this
    @actor-name = name
    #console.log "actor \'", @name, "\' created with id: ", @actor-id
    @msg-serial-number = 0

  send: (msg) ->
    msg = envelp msg, @get-msg-id!
    @send_raw msg

  send_raw: (msg_raw) ->
    msg_raw.sender ++= [@actor-id]
    @mgr.inbox-put msg_raw


  get-msg-id: ->
    msg-id = @actor-id + '.' + String @msg-serial-number
    @msg-serial-number += 1
    return msg-id

class ProxyActor
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass extends Actor
    ~>
      super ...
      #console.log "Proxy actor is created with id: ", @actor-id

      @socket = socket
      # send to server via socket.io
      @socket.on 'aktos-message', (msg) ~>
        try
          @network-rx msg
        catch
          console.log "Problem with receiving message: ", e

      @connected = false 
      @socket.on "connect", !~>
        #console.log "proxy actor says: connected"
        # update io on init
        @connected = true
        @network-tx envelp UpdateIoMessage: {}, @get-msg-id!
        @send ConnectionStatus: {connected: @connected}

      @socket.on "disconnect", !~>
        #console.log "proxy actor says: disconnected"
        @connected = false 
        @send ConnectionStatus: {connected: @connected}
        
    handle_UpdateConnectionStatus: (msg) -> 
      @send ConnectionStatus: {connected: @connected}
      
    network-rx: (msg) ->
      # receive from server via socket.io
      # forward message to inner actors
      #console.log "proxy actor got network message: ", msg
      @send_raw msg

    receive: (msg) ->
      @network-tx msg

    network-tx: (msg) ->
      # receive from inner actors, forward to server
      msg.sender ++= [@actor-id]
      #console.log "emitting message: ", msg
      @socket.emit 'aktos-message', msg

# -----------------------------------------------------
# end of aktos-dcs livescript
# -----------------------------------------------------
/*

# aktos widget library

## basic types:

toggle-switch: toggles on every tap or click
push-button : toggles while clicking or tapping
status-led : readonly of toggle-switch or push-button

*/



get-ractive-variable = (jquery-elem, ractive-variable) ->
  ractive-node = Ractive.get-node-info jquery-elem.get 0
  value = (app.get ractive-node.\keypath)[ractive-variable]
  #console.log "ractive value: ", value
  return value

set-ractive-variable = (jquery-elem, ractive-variable, value) ->
  ractive-node = Ractive.get-node-info jquery-elem.get 0
  if not ractive-node.\keypath
    console.log "ERROR: NO KEYPATH FOUND FOR RACTIVE NODE: ", jquery-elem
    
  app.set ractive-node.\keypath + '.' + ractive-variable, value



class SwitchActor extends Actor
  (pin-name)~>
    super ...
    @callback-functions = []
    @pin-name = String pin-name
    if pin-name
      @actor-name = @pin-name
    else
      @actor-name = @actor-id
      console.log "actor is created with this random name: ", @actor-name
    @ractive-node = null  # the jQuery element
    @connected = false

  add-callback: (func) ->
      @callback-functions ++= [func]

  handle_IoMessage: (msg) ->
    msg-body = get-msg-body msg
    if msg-body.pin_name is @pin-name
      #console.log "switch actor got IoMessage: ", msg
      @fire-callbacks msg-body

  handle_ConnectionStatus: (msg) ->
    # TODO: TEST THIS CIRCULAR REFERENCE IF IT COUSES
    # MEMORY LEAK OR NOT
    @connected = get-msg-body msg .connected
    #console.log "connection status changed: ", @connected
    @refresh-connected-variable! 
    
  refresh-connected-variable: -> 
    if @ractive-node
      #console.log "setting {{connected}}: ", @connected
      set-ractive-variable @ractive-node, 'connected', @connected
    else
      console.log "ractive node is empty! actor: ", this 
    
  set-node: (node) -> 
    #console.log "setting #{this.actor-name} -> ", node
    @ractive-node = node
    
    @send UpdateConnectionStatus: {}

  fire-callbacks: (msg) ->
    #console.log "fire-callbacks called!", msg
    for func in @callback-functions
      func msg

  gui-event: (val) ->
    #console.log "gui event called!", val
    @fire-callbacks do
      pin_name: @pin-name
      val: val

    @send IoMessage: do
      pin_name: @pin-name
      val: val
# ---------------------------------------------------
# END OF LIBRARY FUNCTIONS
# ---------------------------------------------------


set-switch-actors = !->
  $ '.switch-actor' .each !->
    elem = $ this
    pin-name = get-ractive-variable elem, 'pin_name'
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
  $ '.status-led' .each ->
    elem = $ this
    actor = elem.data \actor
    actor.add-callback (msg) ->
      #console.log "status led: ", actor.pin-name, msg.val
      set-ractive-variable elem, 'val', msg.val

set-analog-displays = ->
  $ \.analog-display .each ->
    elem = $ this
    channel-name = get-ractive-variable elem, 'pin_name'
    #console.log "this is channel name: ", channel-name
    actor = SwitchActor channel-name
    actor.add-callback (msg) ->
      set-ractive-variable elem, 'val', msg.val

make-basic-widgets = -> 
  set-switch-buttons!
  set-push-buttons!
  set-status-leds!
  set-analog-displays!

# create jq mobile widgets 
make-jq-mobile-widgets = !->
  console.log "mobile connections being done..."
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
          val = get-ractive-variable elem, \val
          actor.gui-event val
          
        
        slider.on \change ->
          #console.log "slider val: ", slider.val!
          actor.gui-event slider.val!
          
        actor.add-callback (msg)->
          #console.log "slider changed: ", msg.val 
          slider.val msg.val .slider \refresh
          set-ractive-variable elem, \val, msg.val 
        
        
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
    make-windows-size-work!
  
  make-windows-size-work!
  
  

make-line-graph-widget = -> 

  $ \.line-graph .each ->
    elem = $ this 
    pin-name = get-ractive-variable elem, \pin_name 
    actor = SwitchActor pin-name
    
    
    console.log "this is graph widget: ", elem, actor.actor-name
    
    /*
    data = []
    push-graph-data = (new-point) ->
      totalPoints = 300
      console.log "data lenght: ", data.length
      if data.length > 0 then
        data := tail data
      while data.length < total-points 
        data.push new-point
        
    get-graph-data = ->
      # Zip the generated y values with the x values
      zipped = zip [0 to data.length] data
      #console.log "zipped: ", zipped
      return [zipped]
              
    graph-options = do 
      series: 
        shadowSize: 0   # Drawing is faster without shadows
      yaxis: 
        min: 0,
        max: 500
      xaxis: 
        show: false
    
    graph-data = -> 
      return do
        * label: 'test'
          data: get-graph-data!
          color: 'white'
        * label: 'test2'
          data: get-graph-data!
          color: 'red'

    push-graph-data 123
    
    myplot = $.plot '#placeholder', graph-data!, graph-options 
    #myplot.setup-grid!
    
    update-chart = -> 
      #console.log "updating chart...", get-graph-data!
      myplot.set-data graph-data! 
      myplot.draw!
      setTimeout update-chart, 30
      
    update-chart!
      
    actor.add-callback (msg) -> 
      console.log "line-graph got new value: #{msg.val}"
      #push-graph-data msg.val
    */
    #$ -> 
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

/* initialize socket.io connections */
url = window.location.href
arr = url.split "/"
addr_port = arr.0 + "//" + arr.2
socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
socketio-path = join '/' socketio-path
socket = io.connect do 
  'port': addr_port
  'path': socketio-path
  
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
  
  /*
  $ -> 
    data = []
    total-points = 300 
    
    get-random-data = -> 
      if data.length > 0
        data := tail data 
        
      while data.length < total-points
        
        prev = if data.length > 0 then last data else 50
 
        y = prev + Math.random! * 10 - 5        
        y = 0 if y < 0
        y = 100 if y > 100 
        
        #console.log "random data: (y) = #prev"
        data.push y 
      return [zip [0 to total-points] data]
        
    console.log "random data: ", get-random-data! 
    
    update-interval = 30 
    
    plot = $.plot '#placeholder', get-random-data!, do 
      series: 
        shadow-size: 0 
      yaxis: 
        min: 0 
        max: 100 
      xaxis:
        show: false 
    
    update = -> 
      plot.set-data get-random-data!
      plot.draw!
      set-timeout update, update-interval 
      
    update!
  */
  
  /*
  $ (->
    data = []
    getRandomData = ->
      data := data.slice 1 if data.length > 0
      while data.length < totalPoints
        prev = if data.length > 0 then last data else 50
        y = prev + Math.random! * 10 - 5
        if y < 0 then y = 0 else if y > 100 then y = 100
        data.push y

      serie = zip [0 to data.length] data
      return [serie]
      
    update = ->
      plot.setData getRandomData!
      plot.draw!
      setTimeout update, updateInterval
    data = []
    totalPoints = 300
    console.log 'random data: orig: ', getRandomData!
    updateInterval = 30
    plot = $.plot '#placeholder', getRandomData!, {
      series: {shadowSize: 0}
      yaxis: {
        min: 0
        max: 100
      }
      xaxis: {show: false}
    }
    update!)
  */
           
  /*
  ``
    $(function() {

              // We use an inline data source in the example, usually data would
              // be fetched from a server

              var data = [],
                      totalPoints = 300;

              function getRandomData() {

                      if (data.length > 0)
                              data = data.slice(1);

                      // Do a random walk

                      while (data.length < totalPoints) {

                              var prev = data.length > 0 ? data[data.length - 1] : 50,
                                      y = prev + Math.random() * 10 - 5;

                              if (y < 0) {
                                      y = 0;
                              } else if (y > 100) {
                                      y = 100;
                              }

                              data.push(y);
                      }

                      // Zip the generated y values with the x values

                      var res = [];
                      for (var i = 0; i < data.length; ++i) {
                              res.push([i, data[i]])
                      }

                      return res;
              }
                      
              console.log("random data: orig: ", getRandomData()); 

              // Set up the control widget

              var updateInterval = 30;

              var plot = $.plot("#placeholder", [ getRandomData() ], {
                      series: {
                              shadowSize: 0   // Drawing is faster without shadows
                      },
                      yaxis: {
                              min: 0,
                              max: 100
                      },
                      xaxis: {
                              show: false
                      }
              });

              function update() {

                      plot.setData([getRandomData()]);

                      // Since the axes don't change, we don't need to call plot.setupGrid()

                      plot.draw();
                      setTimeout(update, updateInterval);
              }

              update();

      });

  ``
  */
  







