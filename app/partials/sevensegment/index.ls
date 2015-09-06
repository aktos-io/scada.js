require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}
  
RactivePartial! .register ->
  $ \.sevenSeg .each ->
    actor = WidgetActor $ this
    
    display = actor.node
    display.seven-seg do
      digits: 3
      value: 8
      
    actor.add-callback (msg) -> 
      console.log "seven segment display got message: ", msg
      display.seven-seg value: msg.val


  $ \.medsevenSegArray .sevenSeg do
    digits: 5
    value: 12.34
    colorOff: "#003200" 
    colorOn: "Lime"
    slant: 10
