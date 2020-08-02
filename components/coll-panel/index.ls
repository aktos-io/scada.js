Ractive.components['coll-panel'] = Ractive.extend do
    template: require('./index.pug')
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
        show-body: yes
        style: ""
