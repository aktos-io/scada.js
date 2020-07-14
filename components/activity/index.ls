require! 'aea': {sleep}

Ractive.components['activity'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    oninit: ->
        @observe \value, (curr, prev) ->
            if curr?
                if curr isnt prev
                    #console.log "activity, curr: ", curr, "prev: ", prev
                    @set \started, yes
                    @set \active, on
                    <~ sleep 100ms
                    @set \active off

    data: ->
        value: null
        active: off
        started: no
