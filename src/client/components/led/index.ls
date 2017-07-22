Ractive.components['led'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @observe \state, (_new) ->
            if _new? and _new isnt ""
                if _new
                    @set \innerState, \on.svg
                else
                    @set \innerState, \off.svg

    data: ->
        type: \lightbulb
        state: undefined
        inner-state: \unknown.gif
