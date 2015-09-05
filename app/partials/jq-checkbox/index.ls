require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}
  
RactivePartial! .register ->
  $ '.jq-checkbox' .each !->
    elem = $ this
    actor = elem.data \actor
    
    input = elem.find \.jq-checkbox__input

    input.change ->
      console.log "switch button changed: ", input.checked
      actor.gui-event input.is \:checked
    actor.add-callback (msg) ->
      input.prop 'checked', msg.val .checkboxradio \refresh
