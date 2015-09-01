require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    get-ractive-var, 
    set-ractive-var, 
    SwitchActor,
    RactiveApp, 
  }
}
  
RactivePartial! .register -> 
  console.log "this is textbox widget"
  $ \.textbox .each -> 
    elem = $ this
    actor = elem.data \actor
    actor.add-callback (msg) ->
      console.log "textbox partial got message: ", msg.val
      set-ractive-var RactiveApp!get!, elem, 'val', msg.val