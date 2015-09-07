require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}
  
RactivePartial! .register ->
  $ \.toggle-switch .each !->
    elem = $ this
    actor = WidgetActor elem

    s = new ToggleSwitch (elem.get 0), 'on', 'off'
    actor.add-callback (msg) ->
      # prevent switch callback call on
      # external events. only change visual status.
      console.log "toggle-switch status changed externally: ", msg.val
      tmp = s.f-callback
      s.f-callback = null
      if msg.val
        s.on!
      else
        s.off!
      s.f-callback = tmp
      tmp = null

    s.add-listener (state) !->
      console.log "this toggle-switch is changed: #state"
      actor.gui-event state