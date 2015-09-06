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
  }
}


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
    @connected = get-msg-body msg .connected
    #console.log "connection status changed: ", @connected
    @refresh-connected-variable! 
    
  refresh-connected-variable: -> 
    if @ractive-node
      #console.log "setting {{connected}}: ", @connected
      @set-ractive-var 'connected', @connected
    else
      console.log "Can not refresh {{connected}} var: node is empty!", this 
    
  set-node: (node) -> 
    #console.log "setting #{this.actor-name} -> ", node
    @ractive-node = node
    @node = node
    @set-ractive-var = set-ractive-var node 
    @get-ractive-var = get-ractive-var node
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
      
class WidgetActor extends SwitchActor
  (jq-node)~>
    pin-name = get-ractive-var jq-node, 'pin_name'
    super pin-name
    @set-node jq-node

      
module.exports = {
  SwitchActor, WidgetActor
}