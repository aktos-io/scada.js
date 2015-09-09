require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
#RactivePartial! .register ->
RactivePartial! .register-for-document-ready ->
  $ '.jq-push-button' .each ->
    #console.log "found push-button!"
    actor = IoActor $ this
    elem = actor.node 

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
      #console.log "jq-push-button got message: ", msg.val
      if msg.val
        elem.add-class 'ui-btn-active'
      else
        elem.remove-class 'ui-btn-active'
        
