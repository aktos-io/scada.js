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
    elem = actor.node.find \.jq-push-button__button

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable


    # desktop support
    elem.on 'mousedown' ->
      actor.gui-event on
      elem.on 'mouseleave', ->
        actor.gui-event off
        elem.remove-class \ui-focus
    elem.on 'mouseup' ->
      actor.gui-event off
      elem.off 'mouseleave'
      elem.remove-class \ui-focus

    # touch support
    elem.on 'touchstart' (e) ->
      actor.gui-event on
      elem.touchleave ->
        actor.gui-event off
        elem.remove-class \ui-focus

      e.stop-propagation!
    elem.on 'touchend' (e) ->
      actor.gui-event off
      elem.remove-class \ui-focus

    actor.add-callback (msg) ->
      #console.log "jq-push-button got message: ", msg.val
      if msg.val
        elem.remove-class 'btn-default'
        elem.add-class 'btn-active'
      else
        elem.remove-class 'btn-active'
        elem.add-class 'btn-default'
