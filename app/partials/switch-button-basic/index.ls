require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}
  
RactivePartial! .register ->
  $ '.switch-button' .each !->
    elem = $ this
    actor = elem.data \actor

    # make it work without toggle-switch
    # visualisation
    elem.change ->
      actor.gui-event this.checked
    actor.add-callback (msg) ->
      elem.prop 'checked', msg.val
