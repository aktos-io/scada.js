Ractive.components['debug-obj'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    data: ->
        obj: undefined
        title: null
