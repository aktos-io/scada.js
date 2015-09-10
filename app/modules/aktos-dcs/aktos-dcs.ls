
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
    last, 
    empty,
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
    #console.log "ACTOR CREATED: ", @actor-id

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
      @subs-actor-list = []
      #console.log "Manager created with id:", @actor-id

    register: (actor, subscriptions) ->
      if not subscriptions
        @actor-list = @actor-list ++ [actor]
        
        obj = actor 
        meths = [key for key in Object.getOwnPropertyNames(obj) when typeof! obj[key] is 'Function']
        console.log "actor registered: ", meths
      else
        # use subscriptions
        # Subscription format: [MessageSubject, keypath, value]
        # 
        #     eg. ['IoMessage', 'pin_name', 'slider-pin']
        # 
        @subs-actor-list ++= [[actor, subscriptions]]

    inbox-put: (msg) ->
      #msg.sender ++= [@actor-id] performance optimization:
      msg.sender = []  # don't use sender information
      console.log "total actors to forward msg: ", @actor-list.length
      for actor in @actor-list
        if actor.actor-id not in msg.sender
          #console.log "forwarding msg: ", msg
          actor.recv msg
      
      if not empty @subs-actor-list
        forward-counter = 0 
        msg-body = get-msg-body msg
        for [actor, [subj, key, val]] in @subs-actor-list 
        
          if subj of msg.payload 
            # if subject matches
            try 
              if msg-body[key] is val 
                actor.recv msg 
                forward-counter += 1
                
        console.log "total forwards 2: ", forward-counter
          


class Actor extends ActorBase
  (name, subs) ~>
    super ...
    @mgr = ActorManager!
    @mgr.register this, subs 
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
      @connection-listener = (self, connect-str) -> 

      /* initialize socket.io connections */
      url = window.location.href
      arr = url.split "/"
      addr_port = arr.0 + "//" + arr.2
      socketio-path = [''] ++ (initial (drop 3, arr)) ++ ['socket.io']
      socketio-path = join '/' socketio-path
      socket = io.connect do 
        port: addr_port
        path: socketio-path
      
      
      # TODO: erase this, since it's very app specific
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
        console.log "proxy actor says: connected"
        console.log "Connected to server with id: ", @socket.io.engine.id
        @connected = true
        @update-connection-status!
        
      @socket.on "disconnect", !~>
        console.log "proxy actor says: disconnected"
        @connected = false 
        @update-connection-status!
        
    handle_UpdateConnectionStatus: (msg) -> 
      @update-connection-status!
      
    update-connection-status: -> 
      @send ConnectionStatus: {connected: @connected}
      
    network-rx: (msg) ->
      # receive from server via socket.io
      # forward message to inner actors
      #console.log "proxy actor got network message: ", msg
      @send_raw msg

    receive: (msg) ->
      @network-tx-raw msg

    network-tx: (msg) -> 
      @network-tx-raw (envelp msg, @get-msg-id!)

    network-tx-raw: (msg) ->
      # receive from inner actors, forward to server
      msg.sender ++= [@actor-id]
      msg.token = @token
      #console.log "emitting message: ", msg
      @socket.emit 'aktos-message', msg

module.exports = {
  envelp, get-msg-body, Actor, ProxyActor
}
