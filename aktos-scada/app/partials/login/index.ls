require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    AuthActor,
  }
}
  


  
RactivePartial! .register ->
  $ \.login-input .each ->
    actor = AuthActor $ this
    
    input = actor.node.find \input
    
    input.on 'change', -> 
      console.log 'login-input changed: ', input.val!
      
      actor.send-auth-msg input.val!
      
      

RactivePartial! .register ->
  $ \.login-info .each ->
    actor = AuthActor $ this
    
    actor.add-callback (msg)->
      console.log "login-info got client_data: ", msg.client_data
      
      actor.set-ractive-var 'client_name', msg.client_data.name 
      