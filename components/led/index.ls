require! 'dcs/browser': {Actor}

Ractive.components['led'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        @observe \state, (_new) ->
            if _new?
                if _new
                    @set \innerState, \on
                else
                    @set \innerState, \off
            else
                @set \innerState, \unknown

    data: ->
        type: \lightbulb
        state: undefined
        innerState: \unknown
