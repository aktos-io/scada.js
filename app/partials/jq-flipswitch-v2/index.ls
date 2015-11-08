require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register-for-document-ready ->
  $ \.jq-flipswitch-v2 .each ->
    #console.log "switch-button created"
    actor = IoActor $ this

    input = actor.node.find \.jq-flipswitch-v2__switch
    input.bootstrap-switch!

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    input.on 'switchChange.bootstrapSwitch', (event, state) ->
      console.log "jq-checkbox changed: #state"
      actor.gui-event state

    actor.add-callback (msg) ->
      input.bootstrapSwitch 'state', msg.val
