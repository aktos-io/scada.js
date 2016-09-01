require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  $ \.numeric-keyboard .each ->
    #console.log "switch-button created"
    actor = IoActor $ this

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    elem = actor.node.find \table
    #elem.add-class \ui-corner-all

    layout =
      * <[ 1 2 3 a  ]>
      * <[ 4 5 6 b  ]>
      * <[ 7 8 9 c  ]>
      * <[ * 0 \# d ]>

    actor.set-ractive-var \keyboard_data, layout
