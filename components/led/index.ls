require! 'dcs/browser': {Actor}

Ractive.components['led'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        if @get \topic
            actor = new Actor "led:#{that}"
            actor.subscribe that
            actor.on \data, (msg) ~>
                @set \state, msg.payload.curr

            actor.request-update!

        @observe \state, (_new) ->
            if _new? and _new isnt ""
                if _new
                    @set \innerState, \on
                else
                    @set \innerState, \off

    data: ->
        type: \lightbulb
        state: undefined
        innerState: \unknown
