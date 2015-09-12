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
      
      layout = "widget-positions = \n"
      $ \.draggable .each -> 
        wid = $ this .attr \data-wid 
        
        if wid?
          x = $ this .attr \data-x 
          y = $ this .attr \data-y
          
          x = if x? then x else 0 
          y = if y? then y else 0 
          
          console.log "widget found: #wid, #x, #y", $ this 
          
          layout := layout + "  * wid: #wid" + \\n
          layout := layout + "    x: #x" + \\n
          layout := layout + "    y: #y" + \\n
      
      console.log "Layout: " + \\n + layout 
          
          
        
