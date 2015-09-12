require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register-for-document-ready ->
  $ \.thermometer .each !-> 
    actor = IoActor $ this 
    
    #console.log "new thermometer created with id: ", actor.actor-id
    
    therm = new RGraph.Thermometer do
      id: actor.actor-id
      min: 0
      max: 100
      value: 55
      options: do
        scale: {visible: on}
        gutter: {left: 25}
    .grow!
    
    #TODO:see the differences grow and draw function.  
    actor.add-callback (msg) ->
      therm[\value] = if msg.val <= therm.\max then 
        msg.val 
      else 
        therm.\max

      therm.grow!

/*
RactivePartial! .register-for-document-ready ->
  $ \.thermometer .each !-> 
    actor = IoActor $ this 
    
    console.log "dummy plugin in thermometer.ls: ", actor.actor-id
*/