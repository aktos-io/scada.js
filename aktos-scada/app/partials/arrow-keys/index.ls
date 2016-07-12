require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  $ \.arrow-keys .each ->
    console.log "Arrow-keys added"


    # creating actor is a workaround for
    # making available of get-ractive-var method

    actor = IoActor $ this
    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable
