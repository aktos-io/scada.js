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
  $ '.status-led' .each ->
    actor = IoActor $ this 
    

    wid = actor.get-ractive-var \wid
    if wid?
      db = [p for p in wpos when p.wid == wid]
      if not empty db 
        [x, y] = [db.0.x, db.0.y] 
        console.log "status-led: this widget's id: #wid position: ", x, y
        status-led = actor.node
        pos = 'translate(' + x + 'px, ' + y + 'px)'
        status-led.css \webkitTransform, pos
        status-led.css \transform, pos 
      else
        console.log "status-led: no matching widget position found for wid: #wid", db 
    else
      console.log "status-led: no wid found for this widget..."

    
