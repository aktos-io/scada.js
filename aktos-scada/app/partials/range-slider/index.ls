require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    SwitchActor,
    IoActor,
  }
}

# http://refreshless.com/nouislider/examples/

RactivePartial! .register ->
  $ '.range-slider' .each !->
    widget = $ this
    actor = IoActor widget

    second-pin-name = actor.get-ractive-var \pin_name2
    second-actor = SwitchActor second-pin-name

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    slider = widget.find \.slider__inner
    no-ui-slider.create slider.0, do
      start: [null, null]
      connect: true
      behaviour: \drag
      animate: off
      step: 0.1
      range:
        min: [0]
        max: [100]

    slider.0.no-ui-slider.on \slide, (values, handle) ->
      val = values[handle]
      #console.log "slider changed manually:", val, actor.actor-id
      console.log "handle is: ", handle
      if handle is 0
        actor.gui-event val
      else
        second-actor.gui-event val

    actor.add-callback (msg)->
      #console.log "slider received message: ", msg.val, actor.actor-id
      slider.0.no-ui-slider.set [msg.val, null]

    second-actor.add-callback (msg)->
      #console.log "slider received message: ", msg.val, actor.actor-id
      slider.0.no-ui-slider.set [null, msg.val]
