
require! {
  '../prelude': {
    flatten,
    initial,
    drop,
    join,
    concat,
    tail,
    head,
    map,
    zip,
    split,
    union,
    last
  }
}



envelp = (msg, msg-id) ->
  msg-raw =
    sender: []
    timestamp: Date.now! / 1000
    msg_id: msg-id  # {{.actor_id}}.{{serial}}
    payload: msg

get-msg-body = (msg) ->
  subject = [subj for subj of msg.payload][0]
  #console.log "subject, ", subject
  return msg.payload[subject]


class ActorBase
  ~>
    @actor-id = uuid4!

  receive: (msg) ->
    #console.log @name, " received: ", msg.text

  recv: (msg) ->
    @receive msg
    
    
    try
      subjects = [subj for subj of msg.payload]
      for subject in subjects
        try
          this['handle_' + subject] msg
        catch
          @receive msg
    catch
      #console.log "problem in handler: ", e


# make a singleton
class ActorManager
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass extends ActorBase
    ~>
      super ...
      @actor-list = []
      #console.log "Manager created with id:", @actor-id

    register: (actor) ->
      @actor-list = @actor-list ++ [actor]

    inbox-put: (msg) ->
      msg.sender ++= [@actor-id]
      for actor in @actor-list
        if actor.actor-id not in msg.sender
          #console.log "forwarding msg: ", msg
          actor.recv msg


class Actor extends ActorBase
  (name) ~>
    super ...
    @mgr = ActorManager!
    @mgr.register this
    @actor-name = name
    #console.log "actor \'", @name, "\' created with id: ", @actor-id
    @msg-serial-number = 0

  send: (msg) ->
    msg = envelp msg, @get-msg-id!
    @send_raw msg

  send_raw: (msg_raw) ->
    msg_raw.sender ++= [@actor-id]
    @mgr.inbox-put msg_raw


  get-msg-id: ->
    msg-id = @actor-id + '.' + String @msg-serial-number
    @msg-serial-number += 1
    return msg-id




class ProxyActor
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass extends Actor
    ~>
      super ...
      #console.log "Proxy actor is created with id: ", @actor-id
      
      @token = null

      /* initialize socket.io connections */
      url = window.location.href
      arr = url.split "/"
      addr_port = arr.0 + "//" + arr.2
      socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
      socketio-path = join '/' socketio-path
      socket = io.connect do 
        port: addr_port
        path: socketio-path
      
      
      socket.on \frame, (frame) -> 
        $ \#video-frame .attr \src, ('data:image/jpg;base64,' + frame)
      
      @socket = socket
      # send to server via socket.io
      @socket.on 'aktos-message', (msg) ~>
        try
          @network-rx msg
        catch
          console.log "Problem with receiving message: ", e

      @connected = false 
      @socket.on "connect", !~>
        #console.log "proxy actor says: connected"
        console.log "Connected to server with id: ", @socket.io.engine.id
        # update io on init
        @connected = true
        @network-tx (envelp UpdateIoMessage: {}, @get-msg-id!)
        @send ConnectionStatus: {connected: @connected}
        
      @socket.on "disconnect", !~>
        #console.log "proxy actor says: disconnected"
        @connected = false 
        @send ConnectionStatus: {connected: @connected}
            
    handle_UpdateConnectionStatus: (msg) -> 
      @send ConnectionStatus: {connected: @connected}
      
    network-rx: (msg) ->
      # receive from server via socket.io
      # forward message to inner actors
      #console.log "proxy actor got network message: ", msg
      @send_raw msg

    receive: (msg) ->
      @network-tx msg

    network-tx: (msg) ->
      # receive from inner actors, forward to server
      msg.sender ++= [@actor-id]
      msg.token = @token
      #console.log "emitting message: ", msg
      @socket.emit 'aktos-message', msg

module.exports = {
  envelp, get-msg-body, Actor, ProxyActor
}
