require! 'dcs/browser': {AuthActor}

Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    oninit: ->
        @auth = new AuthActor!
        @on do
            do-login: (event, a) ->
                event.component.fire \state, \doing
                err, res <~ @auth.login {username: @get('username'), password: @get('password')}
                if err
                    <~ event.component.fire \error, "something went wrong"
                    #console.log "user pressed button on error screen. "
                    @set \loggedin, no
                else
                    event.component.fire \state, \done...
                    #console.log "login button says: we got: ", res
                    @set \loggedin, yes

                # for debugging purposes only
                @set \token, try
                    res.auth.session.token
                catch
                    void


    data: ->
        loggedin: no
