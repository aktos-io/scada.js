require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register ->
  #console.log "this is textbox widget"
  $ \.textbox .each ->
    elem = $ this
    actor = IoActor elem

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    actor.add-callback (msg) ->
      actor.set-ractive-var 'val', msg.val
