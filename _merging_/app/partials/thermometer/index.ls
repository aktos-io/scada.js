require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
    act-get-range,
  }
}

RactivePartial! .register-for-document-ready ->
  $ \.thermometer .each !->
    actor = IoActor $ this

    #console.log "new thermometer created with id: ", actor.actor-id
    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    [min, max] = act-get-range actor

    therm = new RGraph.Thermometer do
      id: actor.actor-id
      min: min
      max: max
      value: 0
      options:
        gutter: left: 25
    .grow!

    #TODO:see the differences grow and draw function.
    actor.add-callback (msg) ->
      therm[\value] = if msg.val <= therm.\max then
        msg.val
      else
        therm.\max

      therm.grow!

/*
RactivePartial! .register-for-document-ready ->
  $ \.thermometer .each !->
    actor = IoActor $ this

    console.log "dummy plugin in thermometer.ls: ", actor.actor-id
*/
