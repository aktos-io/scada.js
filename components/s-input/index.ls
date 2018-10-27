Ractive.components['s-input'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    data: ->
        readonly: no
        value: undefined
