require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}

RactivePartial! .register-for-document-ready ->
  $ \.switch-button .each ->
    #console.log "switch-button created"
    elem = $ this
    actor = WidgetActor elem

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