Ractive.components['led'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @observe \state, (_new) ->
            if _new is on
                @set \innerState, \on.svg
            else if _new is off
                @set \innerState, \off.svg

    data: ->
        type: \lightbulb
        state: undefined
        inner-state: \unknown.gif
