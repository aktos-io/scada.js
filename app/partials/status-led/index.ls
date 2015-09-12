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
  $ '.status-led' .each ->
    actor = IoActor $ this 
    actor.add-callback (msg) ->
      #console.log "status led: ", actor.pin-name, msg.val
      actor.set-ractive-var 'val', msg.val

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
