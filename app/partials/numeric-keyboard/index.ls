require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}

RactivePartial!register ->
  $ \.numeric-keyboard .each ->
    #console.log "switch-button created"
    elem = $ this
    actor = elem.data \actor

    layout =       
      * <[ 1 2 3 ]>
      * <[ 4 5 6 ]>
      * <[ 7 8 9 ]>

    actor.set-ractive-var \keyboard_data, layout
