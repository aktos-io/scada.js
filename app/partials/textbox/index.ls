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

    actor.add-callback (msg) ->
      actor.set-ractive-var 'val', msg.val
      