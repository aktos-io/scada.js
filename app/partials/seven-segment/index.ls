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
    
    format-prec = ''
    if f.length > 1 
      format-prec = f.1
      digits += format-prec.length
    #console.log "total digits for #type : #digits"
    
    params.digits = digits
    
    height = 50px
    
    
    width = height * 0.75 * digits
    display.css \width, width
    display.css \height, height
    #console.log "height: #height setting width: #width"
      
    if type is \multimeter
      params = $.extend params, do
          color-off: "#003200" 
          color-on: "Lime"

    else if type is \basic
      params = $.extend params, do
        value: 47
        
    
    display.seven-seg params
    
    prec-len = format-prec.length
      
    actor.add-callback (msg) -> 
      #console.log "seven segment display got message: ", msg.val

      value = parse-float msg.val

      # round
      i = 10**prec-len
      value = (Math.round value * i) / i 
      #console.log "rounded value: i, value, prec-len ", msg.val, value, prec-len, i

      if prec-len > 0
        v = String value .split '.'
        v-int = v.0
        
        v-prec = ''
        if v.1
          v-prec = v.1
          
        #console.log 'prec-len ... : ', v, String value, prec-len, v-int, v-prec
        
        if v-prec.length < prec-len
          missing-zero = prec-len - v-prec.length
          v-prec = v-prec + ('0' * missing-zero)
          
        value = v-int + '.' + v-prec
      else 
        value = String value 
      
      v-str = String value .split '.'
      v-str-len = v-str.0.length 
      if v-str.1 
        v-str-len += v-str.1.length 
        
      value = if v-str-len <= digits then 
        value
      else
        '-' * digits 
        
      display.seven-seg value: value
