Ractive.components['debug-obj'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        @observe \obj, (n) ->
            __.set \debuggingObj, n
