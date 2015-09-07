require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ '.status-led' .each ->
    elem = $ this
    actor = IoActor elem
    actor.add-callback (msg) ->
      #console.log "status led: ", actor.pin-name, msg.val
      actor.set-ractive-var 'val', msg.val
