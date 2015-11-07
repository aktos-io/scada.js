require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register ->
  $ '.jq-checkbox' .each !->
    actor = IoActor $ this

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    input = actor.node.find \.jq-checkbox__input

    input.change ->
      state = input.is \:checked
      console.log "jq-checkbox changed: #state"
      actor.gui-event state

    actor.add-callback (msg) ->
      input.prop 'checked', msg.val 
