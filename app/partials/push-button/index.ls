require! {
  '../../modules/aktos-dcs': {
    ProxyActor,
    RactivePartial,
    get-ractive-var, 
    set-ractive-var, 
    SwitchActor,
  }
}
  
RactivePartial! .register ->
  #
  # TODO: tapping works as doubleclick (two press and release)
  #       fix this.
  #
  $ '.push-button' .each ->
    elem = $ this
    pin-name = get-ractive-var elem, 'pin_name'
    actor = SwitchActor pin-name
    actor.set-node elem
    elem.data \actor, actor

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

RactivePartial! .register-for-document-ready ->
    # jq-push-button
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