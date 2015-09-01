require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}
  
RactivePartial! .register ->
  $ '.status-led' .each ->
    elem = $ this
    actor = elem.data \actor
    actor.add-callback (msg) ->
      #console.log "status led: ", actor.pin-name, msg.val
      actor.set-ractive-var 'val', msg.val
