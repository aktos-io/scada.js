require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register-for-document-ready ->
  $ \.justgage .each !-> 
    actor = IoActor $ this 
    
    #console.log "new thermometer created with id: ", actor.actor-id
    
    justgage = new JustGage do
      id: actor.actor-id
      min: 0
      max: 100
      value: 55
      title: 'Tank'
      label: 'litre'

    actor.add-callback (msg) ->
      justgage.refresh msg.val