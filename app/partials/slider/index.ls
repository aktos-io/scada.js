require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}
  
RactivePartial! .register-for-document-ready ->
  $ '.slider' .each !->
    elem = $ this 
    actor = WidgetActor elem
    
    #console.log "this slider actor found: ", actor 
    #debugger 
    
    slider = elem.find \.jq-slider 
    slider.slider!
    #console.log "slider created!", slider
    
    curr_val = slider.attr \value
    slider.val curr_val .slider \refresh 
    #console.log "current value: ", curr_val
    
    input = elem.find \.jq-slider-input
    
    input.on \change -> 
      val = actor.get-ractive-var \val
      actor.gui-event val
      
    
    slider.on \change ->
      console.log "slider val: ", slider.val!
      actor.gui-event slider.val!
      
    actor.add-callback (msg)->
      #console.log "slider changed: ", msg.val 
      slider.val msg.val .slider \refresh
      actor.set-ractive-var  \val, msg.val 