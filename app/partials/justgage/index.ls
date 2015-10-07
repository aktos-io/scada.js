require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
require! {
  '../../modules/prelude': {
    map,
  }
}


RactivePartial! .register-for-document-ready ->
  $ \.justgage .each !->
    actor = IoActor $ this

    #console.log "new thermometer created with id: ", actor.actor-id
    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    type = actor.get-ractive-var \type
    range = (actor.get-ractive-var \range) ? '0 to 100'
    [min, max] = range.split 'to' |> map (.replace /^\s+|\s+$/g, '') |> map (parse-int)

    label = actor.get-ractive-var \label ? 'Test Gauge'

    justgage = new JustGage do
      id: actor.actor-id
      min: min
      max: max
      value: 0
      label: '°C'
      relativeGaugeSize: true

    actor.add-callback (msg) ->
      justgage.refresh msg.val
