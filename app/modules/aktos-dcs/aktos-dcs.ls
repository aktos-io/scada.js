
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
    keys,
  }
}
  
{RactiveApp} = require './widgets'



envelp = (msg, msg-id) ->
  msg-raw =
    sender: []
    timestamp: Date.now! / 1000
    msg_id: msg-id  # {{.actor_id}}.{{serial}}
    payload: msg
    token: ''

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
          #console.log "trying to call handle_#subject()"
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
      @subs-min-list = {}  # 'topic': [list of actors subscribed this topic]
      #console.log "Manager created with id:", @actor-id

    register: (actor, subs) ->
      try
        for topic in subs 
          try
            @subs-min-list[topic] ++= [actor]
          catch
            @subs-min-list[topic] = [actor]
        
        #console.log "actor subscribed with following topics: ", subs
        #console.log "actors subscribed so far: ", @subs-min-list
      catch
        @actor-list = @actor-list ++ [actor]
        #console.log "actor subscribed all topics"

    inbox-put: (msg) ->
      @distribute-msg msg
    
    distribute-msg: (msg) -> 
      msg.sender ++= [@actor-id]  
      # distribute subscribe-all messages 
      for actor in @actor-list
        if actor.actor-id not in msg.sender
          #console.log "forwarding msg: ", msg
          actor.recv msg
      #console.log "forwarded msg count: all: #{@actor-list.length}"
    
      # distribute subscribed messages
      for msg-subject in keys msg.payload
          msg-topic = msg-subject 
          try
            # TODO: do this automatically, this is a workaround!
            if msg-subject is \IoMessage
              #console.log "ActorManager: Special message: IoMessage! msg: ", msg
              msg-topic = join \. [msg-subject, \pin_name, (get-msg-body msg).pin_name]
          catch 
            console.log "problem in creating msg-topic: ", msg

          if @subs-min-list[msg-topic]?

            try
              #console.log "actors will get message: topic: #{msg-topic} ", @subs-min-list[msg-topic]
              for actor in @subs-min-list[msg-topic]
                #console.log "actor will get msg: ", actor
                actor.recv msg
            catch
              console.log "Error forwarding message: ", actor, msg
            
            #console.log "forwarded msg count: Subsc: #{@subs-min-list[msg-topic].length}"
      
class Actor extends ActorBase
  (name) ~>
    super!
    @mgr = ActorManager!
    
    # register message types which are used in this 
    # class with `handle_Subject` format
    #
    
      
    @actor-name = name
    #console.log "actor \'", @name, "\' created with id: ", @actor-id
    @msg-serial-number = 0
    
  list-handle-funcs: -> 
    methods = [key for key of Object.getPrototypeOf this when typeof! this[key] is \Function ]        
    subj = [s.split \handle_ .1 for s in methods when s.match /^handle_.+/]
    #console.log "this actor has the following subjects: ", subj, name
    
  register: -> 
    #console.log "actor will subscribe following topics: ", @subscriptions 
    @mgr.register this, @subscriptions 
    
  send: (msg) ->
    try
      msg-env = envelp msg, @get-msg-id!
      @send_raw msg-env
    catch
      console.log "Error: Actor: sending message failed. msg: ", msg, "enveloped: ", msg-env

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
      @register!
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
