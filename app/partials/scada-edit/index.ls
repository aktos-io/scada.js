require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
require! {
  '../../modules/prelude': {
    empty
  }
}
  
  
  
RactivePartial! .register ->
  $ '.scada-generate-layout' .each !->
    actor = IoActor $ this
    
    input = actor.node

    input.on 'click', ->
      console.log "GENERATE LAYOUT!"
      
      layout = "widget-positions = \n"
      $ '.draggable, .draggable-locked' .each -> 
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
      
      $ '#layout-output-area' .html layout
          
          
        
RactivePartial! .register-for-dynamic-pos (wpos) ->
  $ '.draggable' .each ->
    actor = $ this .data \actor 
    
    if actor?
      wid = actor.get-ractive-var \wid
      widget = actor.node
      if wid?
        db = [p for p in wpos when p.wid == wid]
        if not empty db 
          [x, y] = [db.0.x, db.0.y] 
          console.log "status-led: this widget's id: #wid position: ", x, y
          
          pos = 'translate(' + x + 'px, ' + y + 'px)'
          widget.css \webkitTransform, pos
          widget.css \transform, pos

          # set data-* attributes
          widget.attr \data-x, x 
          widget.attr \data-y, y 
        else
          console.log "status-led: no matching widget position found for wid: #wid", db 
        
        # set widget id anyway
        widget.attr \data-wid, wid 

      else
        console.log "status-led: no wid found for this widget...", wid

    else
      console.log "ERROR: A DRAGGABLE HAS NO ACTOR!"
