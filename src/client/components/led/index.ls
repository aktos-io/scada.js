require! 'dcs/browser': {Actor}

Ractive.components['led'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        if @get \topic
            actor = new Actor "led:#{that}"
            actor.subscribe that
            actor.on \data, (msg) ~>
                @set \state, msg.payload.curr

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
