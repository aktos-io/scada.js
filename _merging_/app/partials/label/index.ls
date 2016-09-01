require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register ->
  $ \.label .each ->
    actor = IoActor $ this
    elem = actor.node

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    actor.add-callback (msg) ->
      actor.set-ractive-var  'val', msg.val
