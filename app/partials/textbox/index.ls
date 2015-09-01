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

    pin_name = get-ractive-var RactiveApp!get!, elem, 'pin_name'
    
    console.log "pin name of textbox: #pin_name"    
    
    keypath = (Ractive.get-node-info elem.get 0).\keypath
    console.log "keypath: ", keypath
    
    actor.add-callback (msg) ->

      #debugger
      RactiveApp!get!set (keypath + '.text'), msg.val
      