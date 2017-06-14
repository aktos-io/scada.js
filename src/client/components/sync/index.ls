require! 'dcs/browser': {IoActor}

Ractive.components['sync'] = Ractive.extend do
    isolated: yes
    oninit: ->
        @actor = new IoActor (@get \name)
        @actor.ractive = this
        @actor.sync \value, (@get \topic), (@get \fps)

    data: ->
        value: null
