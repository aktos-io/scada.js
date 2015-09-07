require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}
  
RactivePartial! .register -> 
  #console.log "this is textbox widget"
  $ \.textbox .each -> 
    elem = $ this
    actor = WidgetActor elem

    actor.add-callback (msg) ->
      actor.set-ractive-var 'val', msg.val
      