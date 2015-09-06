require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    
  }
}


RactivePartial! .register ->
  console.log "Circular-Progress"
  
  $ \#circle .each -> 
    elem = $ this 
    elem.circle-progress do
      value: 0.7
      size: 80
      fill: do
        gradient: ["red", "orange"]
      
      
