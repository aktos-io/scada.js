component-name = "debug-obj"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        @observe \obj, (n) ->
            __.set \debuggingObj, n
