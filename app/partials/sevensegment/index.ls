require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    get-ractive-var, 
    set-ractive-var,
    SwitchActor,
  }
}
  
RactivePartial! .register ->
  $ \.sevenSeg .each ->
    elem = $ this
    actor = elem.data \actor
    elem.sevenSeg do
      value: 8

  $ \.medsevenSegArray .sevenSeg do
    digits: 5
    value: 12.34
    colorOff: "#003200" 
    colorOn: "Lime"
    slant: 10


  