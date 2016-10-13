component-name = "coll-panel"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        expand-button = $ @find \.clickable
        expand-button.on \click, (e) ->
            if __.get \collapsed
                # expand the panel
                __.set \collapsed, no
            else
                # collapse the panel
                __.set \collapsed, yes

    data: ->
        collapsed: yes
        type: \default
