require! 'dcs/browser': {AuthActor}


Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    oninit: ->
        @auth = new AuthActor!
        @on do
            do-login: (event, a) ->
                event.component.fire \state, \doing
                res <~ @auth.login
                event.component.fire \state, \done...
                console.log "login button says: we got: ", res 


    onrender: ->
        @button = @find \ack-button
