require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
  
RactivePartial! .register ->
  $ '.status-led' .each ->
    actor = IoActor $ this 
    actor.add-callback (msg) ->
      #console.log "status led: ", actor.pin-name, msg.val
      actor.set-ractive-var 'val', msg.val

