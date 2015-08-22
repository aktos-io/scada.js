
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
    union
  }
}
/* initialize socket.io connections */
url = window.location.href
arr = url.split "/"
addr_port = arr.0 + "//" + arr.2
socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
socketio-path = join '/' socketio-path
socket = io.connect addr_port, path: socketio-path
## debug
#console.log 'socket.io path: ', addr_port,  socketio-path
#console.log "socket.io socket: ", socket


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

      @socket.on "connect", !~>
        #console.log "proxy actor says: connected"
        # update io on init
        @network-tx envelp UpdateIoMessage: {}, @get-msg-id!
        @send Connection: {connected: true}

      @socket.on "disconnect", !~>
        #console.log "proxy actor says: disconnected"
        @send Connection: {connected: false}


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
      console.log "actor is created with this name: ", @actor-name
    @ractive-node = null  # the jQuery element
    @connected = false

  add-callback: (func) ->
      @callback-functions ++= [func]

  handle_IoMessage: (msg) ->
    msg-body = get-msg-body msg
    if msg-body.pin_name is @pin-name
      #console.log "switch actor got IoMessage: ", msg
      @fire-callbacks msg-body

  handle_Connection: (msg) ->
    # TODO: TEST THIS CIRCULAR REFERENCE IF IT COUSES
    # MEMORY LEAK OR NOT
    @connected = get-msg-body msg .connected
    #console.log "connection status changed: ", @connected
    if @ractive-node
      set-ractive-variable @ractive-node, 'connected', @connected

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

# Create the actor which will connect to the server
ProxyActor!

# Set Ractive.DEBUG to false when minified:
Ractive.DEBUG = /unminified/.test !->
  /*unminified*/

# Initialize Ractive instance
app = new Ractive do
  template: '#app'
  el: 'container'

set-switch-actors = !->
  $ '.switch-actor' .each !->
    elem = $ this
    pin-name = get-ractive-variable elem, 'pin_name'
    actor = SwitchActor pin-name
    actor.ractive-node = elem
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
        console.log "switch-button created"
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
            elem.val \on .flipswitch \refresh
          else
            elem.val \off .flipswitch \refresh
          
          elem.bind \change, send-gui-event 
          
    make-jq-flipswitch-v2!
        
    # jq-push-button
    make-jq-push-button = -> 
      set-push-buttons!  # inherit basic button settings
      $ \.push-button .each ->
        console.log "found push-button!"
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
        
        console.log "this slider actor found: ", actor 
        #debugger 
        
        slider = elem.find \.jq-slider 
        slider.slider!
        console.log "slider created!", slider
        
        curr_val = slider.attr \value
        slider.val curr_val .slider \refresh 
        #console.log "current value: ", curr_val
        
        input = elem.find \.jq-slider-input
        
        input.on \change -> 
          val = get-ractive-variable elem, \val
          actor.gui-event val
          
        
        slider.on \change ->
          console.log "slider val: ", slider.val!
          actor.gui-event slider.val!
          
        actor.add-callback (msg)->
          console.log "slider changed: ", msg.val 
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



  /*
  // Pagecreate will fire for each of the pages in this demo
  // but we only need to bind once so we use "one()"
  $( document ).one( "pagecreate", ".demo-page", function() {
      // Initialize the external persistent header and footer
      $( "#header" ).toolbar({ theme: "b" });
      $( "#footer" ).toolbar({ theme: "b" });
      // Handler for navigating to the next page
      function navnext( next ) {
          $( ":mobile-pagecontainer" ).pagecontainer( "change", next + ".html", {
              transition: "slide"
          });
      }
      // Handler for navigating to the previous page
      function navprev( prev ) {
          $( ":mobile-pagecontainer" ).pagecontainer( "change", prev + ".html", {
              transition: "slide",
              reverse: true
          });
      }
      // Navigate to the next page on swipeleft
      $( document ).on( "swipeleft", ".ui-page", function( event ) {
          // Get the filename of the next page. We stored that in the data-next
          // attribute in the original markup.
          var next = $( this ).jqmData( "next" );
          // Check if there is a next page and
          // swipes may also happen when the user highlights text, so ignore those.
          // We're only interested in swipes on the page.
          if ( next && ( event.target === $( this )[ 0 ] ) ) {
              navnext( next );
          }
      });
      // Navigate to the next page when the "next" button in the footer is clicked
      $( document ).on( "click", ".next", function() {
          var next = $( ".ui-page-active" ).jqmData( "next" );
          // Check if there is a next page
          if ( next ) {
              navnext( next );
          }
      });
      // The same for the navigating to the previous page
      $( document ).on( "swiperight", ".ui-page", function( event ) {
          var prev = $( this ).jqmData( "prev" );
          if ( prev && ( event.target === $( this )[ 0 ] ) ) {
              navprev( prev );
          }
      });
      $( document ).on( "click", ".prev", function() {
          var prev = $( ".ui-page-active" ).jqmData( "prev" );
          if ( prev ) {
              navprev( prev );
          }
      });
  });
  $( document ).on( "pageshow", ".demo-page", function() {
      var thePage = $( this ),
          title = thePage.jqmData( "title" ),
          next = thePage.jqmData( "next" ),
          prev = thePage.jqmData( "prev" );
      // Point the "Trivia" button to the popup for the current page.
      $( "#trivia-button" ).attr( "href", "#" + thePage.find( ".trivia" ).attr( "id" ) );
      // We use the same header on each page
      // so we have to update the title
      $( "#header h1" ).text( title );
      // Prefetch the next page
      // We added data-dom-cache="true" to the page so it won't be deleted
      // so there is no need to prefetch it
      if ( next ) {
          $( ":mobile-pagecontainer" ).pagecontainer( "load", next + ".html" );
      }
      // We disable the next or previous buttons in the footer
      // if there is no next or previous page
      // We use the same footer on each page
      // so first we remove the disabled class if it is there
      $( ".next.ui-state-disabled, .prev.ui-state-disabled" ).removeClass( "ui-state-disabled" );
      if ( ! next ) {
          $( ".next" ).addClass( "ui-state-disabled" );
      }
      if ( ! prev ) {
          $( ".prev" ).addClass( "ui-state-disabled" );
      }
  });
  */


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

  

app.on 'complete', !->
  $ document .ready ->
    #console.log "ractive completed, post processing other widgets..."

    # create actors for every widget
    set-switch-actors!

    # create basic widgets
    #make-basic-widgets!

    # create jquery mobile widgets 
    make-jq-mobile-widgets!

    # set jquery mobile page behaviour
    #make-jq-page-settings!


