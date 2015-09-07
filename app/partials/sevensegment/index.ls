require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ \.seven-segment .each ->
    actor = IoActor $ this
    
    display = actor.node
    
    type = actor.get-ractive-var 'type'
    format = actor.get-ractive-var 'format'
    
    params = 
      digits: 3
      value: 15
      
    f = format.split '.'
    format-int = f.0
    digits = format-int.length
    
    format-prec = 0
    if f.length > 1 
      format-prec = f.1
      digits += format-prec.length
    console.log "total digits for #type : #digits"
    
    params.digits = digits
    
    height = 50px
    
    
    width = height * 0.75 * digits
    display.css \width, width
    display.css \height, height
    console.log "height: #height setting width: #width"
      
    if type is \multimeter
      params.color-on = "yellow"
    else if type is \basic
      params.value = 47
        
    
    display.seven-seg params
      
    actor.add-callback (msg) -> 
      console.log "seven segment display got message: ", msg.val
      
      value = if String msg.val .length <= digits then 
        msg.val 
      else
        '-' * digits 
        
      display.seven-seg value: value


  $ \.medsevenSegArray .sevenSeg do
    digits: 5
    value: 12.34
    colorOff: "#003200" 
    colorOn: "Lime"
    slant: 10
