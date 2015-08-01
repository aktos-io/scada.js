require! {
  'weblib': {
    mk-realtime-input,  mk-radiobox, test: weblib-test, state-of
    radiobox-handler, radiobox-listener-handler, connect-enter-to-click
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


url = window.location.href
arr = url.split "/"
addr_port = arr.0 + "//" + arr.2
socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
socketio-path = join '/' socketio-path
## debug
#console.log 'socket.io path: ' + socketio-path
socket = io.connect addr_port, path: socketio-path

/****************   /GLOBAL VARIABLES **********************/

/****************   SEPARATE LIBRARY TEST **********************/
weblib-test!
/****************   /SEPARATE LIBRARY TEST **********************/

### RACTIVE
app = new Ractive do
  el: 'container'
  template: '#app'
  data:
    welcome: do
        message: 'Egedoz Mühendislik'
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
    @on 'ping', !->
      socket.emit 'server-info', {}
      console.log 'ping sent?'

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

dummy-analog-input = ->
  curr = app.get "analog_input"
  curr = curr + 1
  app.set "analog_input", curr
  set-timeout dummy-analog-input, 1000


socket.on 'analog-simulation', (data) ->
  m = JSON.parse data
  console.log "analog simulation data: ", m.'analog_value'
  app.set 'analog_input', m.'analog_value'


### /RACTIVE


socket.on "connect", ->
  console.log "Connected to the server!"


/****************   CHAT INPUT   **********************/
chat-value = 0

socket.on "tweet", (tweet) ->
  #console.log "tweet from:", tweet.user
  #console.log "contents:", tweet.text
  $ '#messages' .prepend do
    $ '<li>' .text tweet.user + ' says: ' + tweet.text

  chat-value := parse-int tweet.text


$ '#submitbutton'
  .click !->
    console.log 'tweet should be sent...'
    socket.emit 'tweet',
      user: 'chat'
      text: $ '#m' .val!
    new-value = parse-int do
      $ '#m' .val!

    chat-value := new-value
    $ '#m' .val ''

connect-enter-to-click '#m', '#submitbutton'

/****************   /CHAT INPUT   **********************/

/****************   GRAPH   **********************/
data = []
getRandomData = ->
  totalPoints = 300
  if data.length > 0 then
    data := tail data
  while data.length < total-points
    data.push chat-value
  # Zip the generated y values with the x values
  return zip [i for i from 0 to data.length] data

# Set up the control widget
updateInterval = 30

graph-data = ->
  return
    * label: 'test'
      data: get-random-data!
      color: 'red'
    * label: 'test2'
      data: get-random-data!

myplot = $.plot '#placeholder1', graph-data!,
        series:
          shadowSize: 0   # Drawing is faster without shadows
        yaxis:
          min: 0,
          max: 100
        xaxis:
          show: false


/*
get-pie-data = ->
  return
    * label: "seri1"
      data: 1
    * label: "seri2"
      data: 2.5

#console.log "pie data: ", get-pie-data!
pie-plot = $.plot '#pietest', get-pie-data!,
        series:
          pie:
            show: true
            inner-radius: 0.5
*/
update = !->
  myplot.set-data graph-data!
  myplot.draw!

  #pie-plot.set-data get-pie-data!
  #pie-plot.draw!

  setTimeout update, updateInterval

update!
/****************   /GRAPH   **********************/


/****************   REALTIME INPUT   **********************/

realtime-input-changed3 = (elem) ->
  !->
    socket.emit 'tweet',
      user: elem.attr 'id'
      text: elem.val!

mk-realtime-input '.realtime-input', 500, realtime-input-changed3, socket

$ '.radiobox' .each ->
  group = $ this
  group-id = '#' + (group.attr 'id')
  mk-radiobox group-id, radiobox-handler, radiobox-listener-handler, socket
  #console.log 'radiobox ' + group-id + ' created.'

/****************   /REALTIME INPUT   **********************/

/*************** RPI-CLIENT *********************/
$ '#rpi-command' .click ->
  cmd = ($ '#rpi-command').is ':checked'
  cmd-str = if cmd is true then 'turn on' else 'turn off'
  socket.emit 'tweet',
    user: 'command checkbox'
    text: cmd-str
/*************** /RPI-CLIENT *********************/

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
