/*
require! {
  'prelude-ls': {
    flatten
    initial
    drop
    join
    concat
    tail
    head
    map
    zip
    split
    }
}
*/

/*
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
*/

test = ->
  console.log 'weblib library is working!'

# realtime input function
# takes 2 arguments:
# 1. node (one or more objects by passing id or class)
# 2. timeout (send changes after that amount of time in miliseconds)
# 3. handler function (should take node object as input parameter and return callable)
mk-realtime-input = (node, timeout, handler) !->
  $ node .each !->
    elem = $ this
    data-key = 'mk-realtime-input.old-val'
    val-func = -> elem.val!

    # value method is different for checkbox type input
    type-attr = elem.attr 'type'
    if type-attr ? void
      if (elem.attr 'type') is 'checkbox'
        val-func = -> elem.is ':checked'

    elem.data data-key, val-func!

    # Look for changes in the value
    elem.bind "propertychange change click keyup input paste", (event) !->
      if (elem.data data-key) is not val-func!
        elem.data data-key, val-func!

        # debug
        #console.log 'property changed...'

        # do action
        handler-with-parameter = handler elem
        clear-timeout do
          elem.data 'timeout'
        elem.data 'timeout', set-timeout handler-with-parameter, timeout


# rotate : rotates array to the left,
#   so array[i] becomes array[i-1]
rotate = (array) ->
  (tail array) ++ [(head array)]

# returns current visible state of a checkbox
state-of = (elem) ->
  #elem.prop 'checked'
  elem.is ':checked'



# radio buttons with zero or more selection option
# group the buttons by their unique css class
#
# when a checkbox's state is changed, the jQuery object
# is sent to handler
mk-radiobox = (node-id, handler, listener-handler, socket) ->
  # find all checkbox elements
  buttons = []
  $ node-id .children!.each !->
    elem = $ this
    if (elem.attr 'type') is 'checkbox'
      buttons.push elem

  # attach each element's previous and next elements to itself
  buttons1f = rotate buttons
  buttons2f = rotate buttons1f

  for i from 0 to buttons.length - 1
    buttons1f[i].data do
      'next-button'     : buttons2f[i]
      'previous-button' : buttons[i]
      'version'         : 0
      'old-value'       : state-of buttons1f[i]
      'id'              : i
      'group-id'        : node-id
      'edge'            : false

  for button in buttons
    # listen incoming messages
    listener-handler button, socket

    button.bind "propertychange click keyup chain", (event) !->
      current-button = $ event.target
      next-button = current-button.data!.'next-button'
      previous-button = current-button.data!.'previous-button'

      debug-message = ''

      debug-message += 'rb-event-handler: '
      debug-message += (current-button.attr 'value') + ', '
      #console.log 'current button: ', current-button, " next-button: ", next-button
      current-state = state-of current-button

      # this function may be called by previous button
      # update the state if necessary
      if previous-button.data!.'version' > current-button.data!.'version'
        ## debug
        #console.log 'updating version', previous-button.data!.'version'
        current-button.data!.'version' = previous-button.data!.'version'

      debug-message += 'state '
      if current-button.data!.'old-value' is not current-state
        ## debug
        debug-message += 'changed: '
        debug-message += current-button.data!.'old-value'
        debug-message += ' -> '
        # there is a real action
        # increment the version
        current-button.data!.'version' += 1
        # call the handler
        handler current-button, event, socket
        current-button.data!.'old-value' = current-state
        current-button.data!.'edge' = true
      else
        debug-message += ' not changed: '
        current-button.data!.'edge' = false

      debug-message += current-state


      # make next-button update itself:
      if next-button.data!.'version' < current-button.data!.'version'
        ## debug
        #console.log "calling next button: ", (next-button.attr 'value')
        # we should update next button's state
        next-button.trigger 'chain'
      else
        ## debug
        #console.log "next button will not be called."


      ## debug
      console.log debug-message


radiobox-handler = (elem, event, socket) !->
  current-button = elem
  str-join = join ''
  radiobox-message = str-join [
    * (elem.attr 'value')
    * ' is changed to '
    * (state-of elem).to-string!
    ]
  radiobox-gid = elem.data!.'group-id'

  debug-message = ''
  debug-message += 'rb-handler: '
  debug-message += radiobox-gid + ': '
  debug-message += 'event.type: ' + event.type

  if ((state-of current-button) is not current-button.data!.'old-value'
    and event.type is not 'chain')
    socket.emit do
      * 'tweet'
      * user: radiobox-gid
        text: radiobox-message
  if false
    socket.emit do
      * 'tweet'
      * user: 'debug'
        text: str-join [
          * (elem.attr 'value')
          * ': '
          * current-button.data!.\old-value
          * ' -> '
          * (state-of current-button).to-string!
          ]
  ## debug
  #console.log debug-message



radiobox-listener-handler = (elem, socket) !->
  radiobox-gid = elem.data!.'group-id'
  dom-id = elem.attr 'value'
  debug-message1 = ''
  debug-message1 += 'radiobox: '
  debug-message1 += 'handler added for '
  debug-message1 += radiobox-gid + '.' + dom-id

  ## debug
  #console.log debug-message1

  socket.on do
    * 'tweet'
    * (tweet) ->
        # TODO: so many calls made to this handler
        debug-message = ''
        debug-message +=  'rb-receiver: '
        debug-message += radiobox-gid + '.' + dom-id

        if tweet.user is radiobox-gid
          change-log = split ' is changed to ', tweet.text
          debug-message += ', '
          debug-message += join '->' change-log
          if change-log.0 is dom-id
            check-state = (change-log.1 is 'true')
            elem.prop 'checked', check-state

            current-button = elem
            if (state-of current-button) is true
              # uncheck the other buttons
              debug-message += " unchecking other buttons, "
              b = current-button.data!.\next-button
              until b.data!.'id' is current-button.data!.'id'
                ## debug
                #console.log 'looping through button nodes: ', (b)
                b.prop 'checked', false
                b.trigger 'chain'
                b = b.data!.'next-button'

              debug-message += " unchecking other buttons DONE."
            #console.log 'visible state of ' + radiobox-gid + '.' + dom-id + ' changed to ', check-state, elem

        else
          debug-message += ' this msg is NOT for me'

        ## debug
        #console.log debug-message


connect-enter-to-click = (src, target) !->
  $ 'document' .ready !->
      $ src .keypress (e) !->
        if e.keyCode == 13   #the enter key code
          $ target .click!
          #console.log "just like clicked"

module.exports = {
    test,
    mk-realtime-input,
    mk-radiobox,
    rotate,
    state-of,
    radiobox-handler,
    radiobox-listener-handler,
    connect-enter-to-click,
}
