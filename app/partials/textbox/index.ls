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
  #console.log "this is textbox widget"
  $ \.textbox .each -> 
    elem = $ this
    actor = elem.data \actor
    
    get-widget-var = get-ractive-var RactiveApp!get!, elem 
    set-widget-var = set-ractive-var RactiveApp!get!, elem

    pin_name = get-widget-var 'pin_name'
    
    console.log "pin name of textbox: #pin_name"    
    
    actor.add-callback (msg) ->
      set-widget-var 'text', msg.val
      