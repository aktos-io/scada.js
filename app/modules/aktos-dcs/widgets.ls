# make a singleton
class RactivePartial
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass
    ~>
      #super ...
      @widget-inits = []
      @inits-for-document-ready = []

    register: (widget-init) ->
      #console.log "new widget registered: ", widget-init
      @widget-inits ++= [widget-init]

    register-for-document-ready: (widget-init) ->
      #console.log "new widget registered: ", widget-init
      @inits-for-document-ready ++= [widget-init]

    init: ->
      #console.log "initializing ractive partials..."
      for func in @widget-inits
        #console.log "widget init: ", func
        try
          func!
        catch 
          console.log "ERROR ON RactivePartial INIT: #e"
          
    init-for-document-ready: ->   
      #console.log "initializing ractive partials..."
      for func in @inits-for-document-ready
        #console.log "widget init: ", func
        try
          func!
        catch 
          console.log "ERROR ON RactivePartial INIT: #e"
        

get-keypath = (jq-elem) -> 
  app = RactiveApp!get!
  ractive-node = Ractive.get-node-info jq-elem.get 0
  ractive-node.\keypath 
        
get-ractive-var = (jquery-elem, ractive-variable) -->
  app = RactiveApp!get!
  value = (app.get get-keypath jquery-elem)[ractive-variable]
  return value 

set-ractive-var = (jquery-elem, ractive-variable, value) -->
  app = RactiveApp!get! 
  keypath = get-keypath jquery-elem
  if not keypath
    console.log "ERROR: NO KEYPATH FOUND FOR RACTIVE NODE: ", jquery-elem
  else  
    app.set keypath + '.' + ractive-variable, value
    #console.log "setting keypath: ", ractive-node.\keypath
    #console.log "setting keypath: ", ractive-node
    #console.log "set-ractive-var: ", app.nodes
    
  
  
class RactiveApp
  instance = null
  ~>
    instance ?:= SingletonClass!
    return instance

  class SingletonClass
    ~>
      #super ...
      @ractive-app = null

    set: (ractive-app) ->
      #console.log "new widget registered: ", widget-init
      @ractive-app = ractive-app
      
    get: -> 
      @ractive-app


module.exports = {
  RactivePartial, get-ractive-var, set-ractive-var, RactiveApp, get-keypath
}