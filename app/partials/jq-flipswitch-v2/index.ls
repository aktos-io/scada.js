require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register-for-document-ready ->
  $ \.jq-flipswitch-v2 .each ->
    #console.log "switch-button created"
    actor = IoActor $ this 

    elem = actor.node.find \.jq-flipswitch-v2__switch
    
    if (actor.get-ractive-var \wid)? 
      actor.node.add-class \draggable 

    
    send-gui-event = (event) -> 
      #console.log "jq-flipswitch-2 sending msg: ", elem.val!        
      actor.gui-event (elem.val! == \on)

    elem.on \change, send-gui-event
    
    actor.add-callback (msg) ->
      #console.log "switch-button got message", msg
      elem.unbind \change
      
      if msg.val
        elem.val \on .slider \refresh
      else
        elem.val \off .slider \refresh
      
      elem.bind \change, send-gui-event 