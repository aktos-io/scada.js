require! {
  './aktos-dcs': {
    envelp,
    get-msg-body,
    Actor,
  }
}

require! {
  './widgets': {
    get-ractive-var,
    set-ractive-var,
    RactiveApp,
    get-keypath,
  }
}


class SwitchActor extends Actor
  (pin-name)~>
    super pin-name

    if pin-name
      @subscriptions =
        * \IoMessage.pin_name. + pin-name
        * \ConnectionStatus

    @register!
    @callback-functions = []
    @pin-name = (String pin-name) ? @actor-id

    #console.log "actor is created with this random name: ", @actor-name
    @ractive-node = null  # the jQuery element
    @connected = false
    @set-ractive-var = null
    @get-ractive-var = null

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
    @connected = (get-msg-body msg).connected
    #console.log "connection status changed: ", @connected
    @refresh-connected-variable!

  refresh-connected-variable: ->
    if @ractive-node
      #console.log "setting {{connected}}: ", @connected
      @set-ractive-var 'connected', @connected
    else
      #console.log "Can not refresh {{connected}} var: node is empty!", this

  set-node: (node) ->
    #console.log "setting #{this.actor-name} -> ", node
    @ractive-node = node
    @node = node
    @set-ractive-var = set-ractive-var node
    @get-ractive-var = get-ractive-var node

  fire-callbacks: (msg) ->
    #console.log "fire-callbacks called!", msg
    for func in @callback-functions
      func msg

  gui-event-base: (val) ->
    #console.log "gui event called!", val
    @fire-callbacks do
      pin_name: @pin-name
      val: val

    @send IoMessage: do
      pin_name: @pin-name
      val: val

  gui-event: (val) ->
    @gui-event-base val

  get-keypath: ->
    get-keypath @node


class IoActor extends SwitchActor
  (jq-node)~>
    saved-actor = jq-node.data \actor
    if saved-actor
      #console.log "this actor created before? because current actor-id: ", saved-actor.actor-id
      return saved-actor
    pin-name = get-ractive-var jq-node, 'pin_name'
    super pin-name
    @set-node jq-node
    set-ractive-var jq-node, 'actor_id', @actor-id
    set-ractive-var jq-node, 'debug', false
    # save this actor in node's data-actor attribute for
    # further usages
    jq-node.data \actor, this

  gui-event: (val) ->
    if @node.has-class \read-only
      console.log "not sending msg, this widget is read-only!"
    else
      @gui-event-base val

class WidgetActor extends IoActor
  ~>
    super ...


class AuthActor extends IoActor
  ~>
    super ...
    @subscriptions = ['AuthMessage']
    @register!

  send-auth-msg: (secret) ->
    # authentication
    auth-msg = AuthMessage:
      client_secret: secret
    @send auth-msg

  handle_AuthMessage: (msg) ->
    msg-body = get-msg-body msg
    #console.log "AuthActor got control message: ", msg-body
    if \token of msg-body
      @token = msg-body.token
      #console.log "AuthActor got token: ", @token

    @fire-callbacks msg-body

  handle_IoMessage: (msg) ->


module.exports = {
  SwitchActor, WidgetActor, IoActor, AuthActor,
}
