Ractive.components['json-edit'] = Ractive.extend do
  template: require('./json-edit.pug')
  isolated: true
  data: -> 
    objStr: null 
    objFormatted: null 
  computed: 
    objFormatted: 
      get: ->
        if @get \objTmp
            return that 
        else 
            return JSON.stringify @get('value'), null, 2

      set: (objStr) -> 
        try 
          obj = JSON.parse(objStr)
          @set('value', obj)
          @set('objTmp', null)
        catch
          return @set 'objTmp', objStr

Ractive.components['debug-obj'] = Ractive.extend do
    template: require('./index.pug')
    data: ->
        obj: null
        title: null
        public: false
