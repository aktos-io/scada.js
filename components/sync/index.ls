require! 'dcs/browser': {IoActor}

Ractive.components['sync'] = Ractive.extend do
    isolated: yes
    onrender: ->
        @actor = new IoActor (@get \name)
        @actor.ractive = this
        @actor.sync \value, (@get \topic), (@get \fps)

        @actor.on \receive, (msg) ~>
            @fire \receive, msg

        @actor.request-update!

    unrender: ->
        @actor.kill \unrender

    data: ->
        value: null
