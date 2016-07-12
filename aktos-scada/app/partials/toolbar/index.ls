require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial! .register-for-document-ready ->
  $ '.toolbar-icons a' .on \click, (event) ->
    event.preventDefault!

  $ \.toolbar .each ->

    actor = IoActor $ this
    elem = actor.node

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    tb = elem.find ('#' + actor.actor-id)
      
    tb.toolbar do
      content: '#' + actor.actor-id + '-options'
      position: 'top',
      style: 'primary',
      event: 'click',
      hideOnClick: true
