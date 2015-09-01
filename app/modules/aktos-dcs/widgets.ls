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

    register: (widget-init) ->
      #console.log "new widget registered: ", widget-init
      @widget-inits ++= [widget-init]

    init: ->
      console.log "initializing ractive partials..."
      for func in @widget-inits
        #console.log "widget init: ", func
        func!

get-ractive-var = (app, jquery-elem, ractive-variable) ->
  ractive-node = Ractive.get-node-info jquery-elem.get 0
  value = (app.get ractive-node.\keypath)[ractive-variable]
  #console.log "ractive value: ", value
  return value

set-ractive-var = (app, jquery-elem, ractive-variable, value) ->
  ractive-node = Ractive.get-node-info jquery-elem.get 0
  if not ractive-node.\keypath
    console.log "ERROR: NO KEYPATH FOUND FOR RACTIVE NODE: ", jquery-elem
    
  app.set ractive-node.\keypath + '.' + ractive-variable, value
  
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
  RactivePartial, get-ractive-var, set-ractive-var, RactiveApp
}