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

    input.change ->
      #console.log "switch button changed: ", (input.prop \checked)
      actor.gui-event input.prop \checked
    actor.add-callback (msg) ->
      input.prop 'checked', msg.val
