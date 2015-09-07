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
  
    actor.set-ractive-var 'actor_id', actor.actor-id
    
    tb = elem.find ('#' + actor.actor-id)
      
    tb.toolbar do
      content: '#' + actor.actor-id + '-options'
      position: 'top',
      style: 'primary',
      event: 'click',
      hideOnClick: true
      
      