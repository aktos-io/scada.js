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

ProxyActor!


class TestActor extends Actor
  ~>
    super ...

test1 = TestActor "test1"
test2 = TestActor "test2"
test3 = TestActor "test3"

test1.send PingMessage: {text: "test 1 sending"}

class Ponger extends Actor
  ~>
    super ...

  receive: (msg) ->
    console.log "Ponger received message:" , msg
    #console.log "Ponger sending PingMessage..."
    #@send PingMessage: {text: "browser ponger send ping message..."}

ponger = Ponger!
/*
set-interval (->
  test3.send PingMessage: {text: "test 3 sending"}),
  2000
*/

### RACTIVE INIT
app = new Ractive do
  template: '#app'
  el: 'container'
  data:
    welcome: do
        message: 'Aktos Elektronik'
        version: '0.8'
    connected: false
    messages: []
    analog_input: 'UNKNOWN'
    io_button:
      * type: 'output'
        pins:
          * pin   : 17
            state : false
          * pin   : 27
            state : false
          * pin   : 22
            state : false
      * type: 'input'
        pins:
          * pin   : 25
            state : false
          * pin   : 24
            state : false
  onrender: (options) !->
    @set "text", "initial text value"
    console.log 'just rendered...'
### /RACTIVE INIT

set-switch-buttons = !->
  $ '.toggle-switch' .each !->
    console.log 'toggle-switch made'
    elem = $ this
    elem-dom = elem.0
    pin-id = parse-int (elem.prop 'value')
    s = new ToggleSwitch elem-dom, 'on', 'off'
    s.add-listener (state) !->
      set-digital-output pin-id, state

app.on 'complete', !->
  set-switch-buttons!
  #dummy-analog-input!
  console.log "ractive completed?"

dummy-analog-input = ->
  curr = app.get "analog_input"
  curr = curr + 1
  app.set "analog_input", curr
  set-timeout dummy-analog-input, 1000


  #app.set 'analog_input', m.'analog_value'


console.log app

### /RACTIVE




# ------- switch



socket.on "connect", !->
  app.set "connected", true

socket.on "tweet", (tweet) !->
  messages = app.get "messages"
  messages = [tweet] ++ messages
  console.log "messages: ", messages
  app.set "messages", messages

rpi-command-output = (event) !->
  console.log "cmd is: ", cmd, event.context
  cmd = $ event.original.target .is ':checked'
  socket.emit 'rpi-io-command',
    turn: cmd
    pin: event.context.pin

set-digital-output = (pin-id, state) !->
  console.log 'set-digital-output: ', pin-id, state
  socket.emit 'rpi-io-command',
    turn: state
    pin: pin-id


switch-state-change = (event, state) !->
  console.log "state: ", state

# wire the events with handlers
app.on 'rpi-command-output', rpi-command-output

socket.on 'rpi-io-input', (data) !->
  console.log "data from rpi-io-input: ", data
  io_button = app.get 'io_button'
  for i in io_button.1.pins
    if data.'gpio-pin-number' is i.pin
      i.state = data.state
  app.set 'io_button', io_button

socket.on 'disconnect', !->
  console.log 'disconnected...'
  app.set 'connected', false
