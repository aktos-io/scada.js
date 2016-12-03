component-name = "debug-obj"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: yes
    onrender: ->
        __ = @
        @observe \obj, (n) ->
            __.set \debuggingObj, n
