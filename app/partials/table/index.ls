require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register ->
  $ \.table .each ->
    #console.log "switch-button created"
    elem = $ this
    actor = IoActor elem

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    actor.add-callback (msg) ->
      console.log "table got message", msg
      actor.set-ractive-var \table_data, msg.table_data
