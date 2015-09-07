require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  $ \.numeric-keyboard .each ->
    #console.log "switch-button created"
    elem = $ this
    actor = IoActor elem

    layout =       
      * <[ 1 2 3 a  ]>
      * <[ 4 5 6 b  ]>
      * <[ 7 8 9 c  ]>
      * <[ * 0 \# d ]>

    actor.set-ractive-var \keyboard_data, layout
