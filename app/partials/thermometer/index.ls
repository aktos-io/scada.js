require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}
  
RactivePartial! .register ->
  console.log "meleba"
  $ \.thermometer .each !-> 
  
    elem = $ this
    actor = elem.data \actor
    
    element-id = actor.actor-id
    actor.set-ractive-var 'actor_id', element-id
    
    therm = new RGraph.Thermometer do
      id: element-id
      min: 0
      max: 100
      value: 55
      options: do
        scale: {visible: on}
        gutter: {left: 25}
    .grow!
    
    #TODO:see the differences grow and draw function.  
    actor.add-callback (msg) ->
      therm[\value] = if msg.val <= therm.\max then msg.val else therm.\max
      therm.draw!
