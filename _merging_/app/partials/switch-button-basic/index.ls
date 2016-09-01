require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register ->
  $ '.switch-button-basic' .each !->
    actor = IoActor $ this

    input = actor.node.find \.switch-button-basic__input

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    change-handler = ->
      #console.log "switch button changed: ", (input.prop \checked)
      actor.gui-event input.prop \checked
    input.change change-handler

    actor.add-callback (msg) ->
      input.off \change
      input.prop \checked, msg.val
      input.change change-handler
