require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
  }
}
  
class LoginActor extends WidgetActor
  ~>
    super ...
    
  handle_LoginMessage: (msg) -> 
    console.log "Login message received: ", msg
  
  
RactivePartial! .register ->
  $ \.login-input .each ->
    actor = LoginActor $ this
    
    input = actor.node.find \input
    
    input.on 'change', -> 
      console.log 'login-input changed: ', input.val!
      
      actor.send ProxyActorMessage:
        client_secret: input.val!
      