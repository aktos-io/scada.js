require! 'dcs/browser': {AuthActor}

Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        @button = @find \ack-button
