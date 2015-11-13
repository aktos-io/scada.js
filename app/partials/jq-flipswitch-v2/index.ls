require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

# http://www.bootstraptoggle.com/

RactivePartial! .register-for-document-ready ->
  i = 0
  $ \.jq-flipswitch-v2 .each ->
    console.log "switch-button no #{i} created"
    i := i + 1

    actor = IoActor $ this

    input = actor.node.find \.jq-flipswitch-v2__switch
    input.bootstrap-toggle!

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable


    change-handler = ->
      state = input.prop \checked
      console.log "bootstrap-toggle changed: #state"
      actor.gui-event state

    input.change change-handler

    actor.add-callback (msg) ->
      console.log "bootstrap-toggle received message"

      input.off \change
      input.prop \checked, msg.val .change!
      input.change change-handler
