require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ '.b-progress-bar' .each !->
    elem = $ this 
    actor = IoActor elem
    
    actor.add-callback (msg)->
      #console.log "slider changed: ", msg.val 
      actor.set-ractive-var  \val, msg.val 