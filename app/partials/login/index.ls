require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    WidgetActor,
    get-msg-body,
  }
}
  
class AuthActor extends WidgetActor
  ~>
    super ...
    
  send-auth-msg: (secret) ->
    # authentication
    auth-msg = AuthMessage:
      client_secret: secret
    @send auth-msg
    
  handle_AuthMessage: (msg) -> 
    msg-body = get-msg-body msg
    #console.log "AuthActor got control message: ", msg-body
    if \token of msg-body
      @token = msg-body.token
      #console.log "AuthActor got token: ", @token

    @fire-callbacks msg-body
    
  handle_IoMessage: (msg) ->
  


  
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
      