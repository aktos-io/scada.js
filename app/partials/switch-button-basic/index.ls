require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ '.switch-button-basic' .each !->
    elem = $ this
    actor = IoActor elem

    elem.change ->
      console.log "switch button changed: ", this.checked
      actor.gui-event this.checked
    actor.add-callback (msg) ->
      elem.prop 'checked', msg.val
