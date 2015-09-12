require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  $ \.online-users .each ->
    #console.log "switch-button created"
    actor = IoActor $ this 

    actor.add-callback (msg) -> 
      actor.set-ractive-var \val, msg.val 
      
