require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ \.b-slider .each !->   
    actor = IoActor $ this 
    
    slider = actor.node.find \b-slider__input
    slider.bss_slider!
        
    actor.add-callback (msg) ->
      slider \setValue, msg.val
      
    /*
    slider.slide -> 
      actor.gui-event slider.slider \getValue
    */