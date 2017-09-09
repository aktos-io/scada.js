require! 'dcs/browser': {IoActor}

Ractive.components['sync'] = Ractive.extend do
    isolated: yes
    onrender: ->
        @actor = new IoActor this, (@get \topic)
        @actor.sync \value, (@get \topic), (@get \fps)

        @actor.on \receive, (msg) ~>
            @fire \receive, msg

        @actor.request-update!

    data: ->
        value: null
