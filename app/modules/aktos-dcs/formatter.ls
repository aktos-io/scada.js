require! {
  '../prelude': {
    split,
    last, 
  }
}
  
formatter = (format, value) --> 
  # format: ###.## km/h
  # output: 
  #   number: 123.45 
  #   unit:   km/h
  #   digits: 5
  
  unit = format.replace /[#\.\s]/g, ''
  format-parts = format.match /#+\.?#*/
  number-part = format-parts.0 
  
  unit-right-hand = if format-parts.index is 0 then yes else no 

  value = if value? then 
    parse-float value
  
  f = number-part.split '.'
  format-int = f.0
  digits = format-int.length

  format-prec = ''
  if f.length > 1 
    format-prec = f.1
    digits += format-prec.length
  #console.log "total digits for #type : #digits"
  
  undefined-input = '-' * digits 
  
  if value? 
    prec-len = format-prec.length
    #console.log "seven segment display got message: ", msg.val
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
      undefined-input 
    
    value-str = if unit-right-hand then 
      value + ' ' + unit
    else
      unit + ' ' + value 
  else
    value = undefined-input 
    value-str = undefined-input

  output =
    value: value
    value-str: value-str 
    unit: unit
    digits: digits 
    unit-right-hand: unit-right-hand 
    unit-left-hand: not unit-right-hand 
    
  #console.log "output: ", output
    
  return output


module.exports = {
  formatter,
}