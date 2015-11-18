require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

# http://refreshless.com/nouislider/examples/

RactivePartial! .register ->
  $ '.slider' .each !->
    widget = $ this
    actor = IoActor widget

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    slider = widget.find \.slider__inner
    no-ui-slider.create slider.0, do
      start: null
      connect: \lower
      step: 0.1
      range:
        min: [0]
        max: [100]

    slider.0.no-ui-slider.on \slide, (values, handle) ->
      val = values[handle]
      #console.log "slider changed manually:", val, actor.actor-id
      actor.gui-event val

    actor.add-callback (msg)->
      #console.log "slider received message: ", msg.val, actor.actor-id
      slider.0.no-ui-slider.set msg.val
