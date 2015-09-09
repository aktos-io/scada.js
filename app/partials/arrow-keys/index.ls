require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  $ \.arrow-keys .each ->
    console.log "Arrow-keys added"
    