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


module.exports = {
  RactivePartial
}