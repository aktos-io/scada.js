require! {
  './weblib': {
    mk-realtime-input,
    mk-radiobox,
    test: weblib-test,
    state-of
    radiobox-handler,
    radiobox-listener-handler,
    connect-enter-to-click
    }
}

flatten = prelude.flatten
initial = prelude.initial
drop = prelude.drop
join = prelude.join
concat = prelude.concat
tail = prelude.tail
head = prelude.head
map = prelude.map
zip = prelude.zip
split = prelude.split
union = prelude.union

/* initialize socket.io connections */
url = window.location.href
arr = url.split "/"
addr_port = arr.0 + "//" + arr.2
socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
socketio-path = join '/' socketio-path
## debug
#console.log 'socket.io path: ' + socketio-path
socket = io.connect addr_port, path: socketio-path

# -----------------------------------------------------
# aktos-dcs livescript
# -----------------------------------------------------
class ActorBase
  ~>
    @actor-id = uuid4!

  receive: (msg) ->
    #console.log @name, " received: ", msg.text

  recv: (msg) ->
    @receive msg
    try
      this['handle_' + msg.cls] msg
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
    @name = name
    #console.log "actor \'", @name, "\' created with id: ", @actor-id

  send: (msg) ->
    msg = @fill-msg msg
    msg.sender ++= [@actor-id]
    @mgr.inbox-put msg

  copy-msg: (msg) ->
    JSON.parse JSON.stringify msg

  fill-msg: (msg) ->
    cls = Object.keys msg .0
    msg = @copy-msg msg[cls]
    msg.cls = cls
    msg.sender ?= []
    msg.timestamp ?= Date.now! / 1000 or 0
    msg.msg_id = uuid4!
    #console.log "filled msg: ", msg
    return msg


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
        @connected = true
        #console.log "proxy actor says: connected=", @connected

      @socket.on "disconnect", !~>
        @connected = false
        #console.log "proxy actor says: connected=", @connected

    network-rx: (msg) ->
      # receive from server via socket.io
      # forward message to inner actors
      @send msg

    fill-msg: (msg) ->
      msg

    receive: (msg) ->
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

class SwitchActor extends Actor
  (pin-name)~>
    super ...
    @listener-functions = []
    @pin-name = String pin-name

    # update io on init
    @send UpdateIoMessage: {}

  add-listener: (func) ->
      @listener-functions ++= [func]

  handle_IoMessage: (msg) ->
    #console.log "switch actor got IoMessage: ", msg
    if msg.pin_name is @pin-name
      for func in @listener-functions
        func msg

  send-event: (val) ->
    #console.log "sending event: ", @pin-name, val
    @send IoMessage: do
      pin_name: @pin-name
      val: val

# Create the actor which will connect to the server
ProxyActor!

### RACTIVE INIT
app = new Ractive do
  template: '#app'
  el: 'container'
  data:
    connected: false
  onrender: (options) !->
    @set "text", "initial text value"
    console.log 'just rendered...'
### /RACTIVE INIT

set-switch-buttons = !->
  $ '.toggle-switch' .each !->
    elem = $ this
    elem-dom = elem.0
    pin-id = elem.prop 'value'
    actor = SwitchActor pin-id

    # make it work without toggle-switch
    # visualisation
    elem.change ->
      actor.send-event this.checked
    actor.add-listener (msg) ->
      elem.prop 'checked', msg.val

    # apply toggle-switch visualisation
    s = new ToggleSwitch elem-dom, 'on', 'off'
    actor.add-listener (msg) ->
      if msg.val
        s.on!
      else
        s.off!
    s.add-listener (state) !->
      actor.send-event state

    console.log 'toggle-switch made'

set-push-buttons = ->
  $ '.push-button' .each ->
    jq-elem = $ this
    pin-name = jq-elem.data 'pin-name'
    actor = SwitchActor pin-name
    jq-elem.on 'mousedown touchstart' ->
      jq-elem.add-class 'button-active-state'
      actor.send-event on
      jq-elem.on 'mouseleave', ->
        jq-elem.remove-class 'button-active-state'
        actor.send-event off
    jq-elem.on 'mouseup touchend touchcancel touchmove' ->
      jq-elem.remove-class 'button-active-state'
      actor.send-event off
      jq-elem.off 'mouseleave'

    actor.add-listener (msg) ->
      #console.log "push button got message: ", msg
      if msg.val
        jq-elem.add-class 'button-active-state'
      else
        jq-elem.remove-class 'button-active-state'
      # disable mouseout event for the external events

set-status-leds = ->
  $ '.status-led' .each ->
    jq-elem = $ this
    pin-name = jq-elem.data 'pin-name'
    actor = SwitchActor pin-name
    actor.add-listener (msg) ->
      console.log "push button got message: ", msg
    console.log jq-elem

app.on 'complete', !->
  console.log "ractive completed, post processing other widgets..."
  set-switch-buttons!
  set-push-buttons!
  set-status-leds!
  #dummy-analog-input!

### /RACTIVE


socket.on "connect", !->
  app.set "connected", true

socket.on 'disconnect', !->
  console.log 'disconnected...'
  app.set 'connected', false
