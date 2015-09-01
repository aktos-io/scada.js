require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    get-ractive-var, 
    set-ractive-var,
    SwitchActor,
  }
}
  
RactivePartial! .register ->
  $ \.analog-display .each ->
    elem = $ this
    channel-name = get-ractive-var  elem, 'pin_name'
    #console.log "this is channel name: ", channel-name
    actor = SwitchActor channel-name
    actor.add-callback (msg) ->
      set-ractive-var  elem, 'val', msg.val
