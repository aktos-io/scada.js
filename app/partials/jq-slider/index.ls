require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register-for-document-ready ->
  $ '.jq-slider' .each !->
    elem = $ this 
    actor = IoActor elem
    
    #console.log "this slider actor found: ", actor 
    #debugger 
    
    slider = elem.find \.jq-slider__container 
    slider.slider!
    #console.log "slider created!", slider
    
    #curr_val = slider.attr \value
    #slider.val curr_val .slider \refresh 
    #console.log "current value: ", curr_val
    
    slider.on \change ->
      #console.log "slider val: ", slider.val!
      actor.gui-event slider.val!
      
    actor.add-callback (msg)->
      #console.log "slider changed: ", msg.val 
      actor.set-ractive-var  \val, msg.val 
      slider.slider \refresh
      