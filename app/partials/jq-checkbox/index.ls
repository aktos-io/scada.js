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
      state = input.is \:checked
      console.log "jq-checkbox changed: #state"
      actor.gui-event state
      
    actor.add-callback (msg) ->
      input.prop 'checked', msg.val .checkboxradio \refresh
