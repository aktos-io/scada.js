require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    get-ractive-var, 
    set-ractive-var, 
    RactiveApp, 
  }
}
  
RactivePartial! .register -> 
  #console.log "this is textbox widget"
  $ \.textbox .each -> 
    elem = $ this
    actor = elem.data \actor
    get-widget-var = get-ractive-var elem 
    set-widget-var = set-ractive-var elem

    actor.add-callback (msg) ->
      set-widget-var 'val', msg.val
      