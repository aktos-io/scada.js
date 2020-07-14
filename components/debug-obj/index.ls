Ractive.components['debug-obj'] = Ractive.extend do
    template: require('./index.pug')
    data: ->
        obj: undefined
        title: null
        public: false
