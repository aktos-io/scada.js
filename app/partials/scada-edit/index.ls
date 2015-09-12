require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ '.scada-generate-layout' .each !->
    actor = IoActor $ this
    
    input = actor.node

    input.on 'click', ->
      console.log "GENERATE LAYOUT!"
      
      $ \.draggable .each -> 
        wid = $ this .attr \data-wid 
        
        if wid?
          x = $ this .attr \data-x 
          y = $ this .attr \data-y
          
          console.log "widget found: #wid, #x, #y", $ this 
        
