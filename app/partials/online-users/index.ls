require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register-for-document-ready ->
  $ \.online-users .each ->
    #console.log "switch-button created"
    actor = IoActor $ this 

    actor.add-callback (msg) -> 
      console.log "online-users got message: ", msg
      actor.set-ractive-var \val, msg.val 

    actor.send UpdateIoMessage: {}