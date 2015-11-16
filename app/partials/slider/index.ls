require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register-for-document-ready ->
  $ '.slider' .each !->
    widget = $ this
    actor = IoActor widget

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    slider = widget.find \.slider__inner
    no-ui-slider.create slider.0, do
      start: [ 80 ]
      connect: \lower
      range:
        min: [0]
        max: [100]

    slider.0.no-ui-slider.on \update, (values, handle) ->
      val = values[handle]
      console.log "slider val: ", val
      actor.gui-event val

    actor.add-callback (msg)->
      console.log "slider changed: ", msg.val
      #slider.0.no-ui-slider.set msg.val
