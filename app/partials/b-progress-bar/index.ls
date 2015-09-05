require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}
  
RactivePartial! .register ->
  $ '.b-progress-bar' .each !->
    elem = $ this 
    actor = elem.data \actor
    
    actor.add-callback (msg)->
      #console.log "slider changed: ", msg.val 
      actor.set-ractive-var  \val, msg.val 