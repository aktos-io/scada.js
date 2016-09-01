require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ \.simple-display .each ->
    actor = IoActor $ this 
    elem = actor.node
    actor.add-callback (msg) ->
      actor.set-ractive-var  'val', msg.val
