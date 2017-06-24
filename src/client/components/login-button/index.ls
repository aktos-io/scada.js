require! 'dcs/browser': {AuthActor}
require! 'aea': {sleep}

Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    oninit: ->
        @auth = new AuthActor!
        @on do
            do-login: (event) ->
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

            do-logout: (event) ->
                event.component.fire \state, \doing
                err, res <~ @auth.logout
                if err
                    <~ event.component.fire \error, "something went wrong while logging out"
                    #console.log "user pressed button on error screen. "
                    @set \loggedin, yes
                else
                    event.component.fire \state, \done...
                    console.log "login button says: we got: ", res
                    @set \loggedin, no



            do-action: (event) ->
                if @get(\action) is \logout
                    @fire \doLogout, event
                else
                    @fire \doLogin, event

    onrender: ->
        <~ sleep 500ms
        ack-button = @find-component \ack-button
        ack-button.fire \state, \doing
        err, res <~ @auth.check-session
        ack-button.fire \state, \normal
        unless err
            if res.auth.logout is \yes
                console.log "logging out"
                @set \loggedin, no
            else if res.auth.session
                console.log "server says we are logged in as #{res.auth.session.user}"
                @set \username, res.auth.session.user
                @set \loggedin, yes
            else
                console.warn "unknown response: ", res
        else
            unless err.code is \singleton
                console.warn "something went wrong while checking the session, err: ", err


    data: ->
        loggedin: no
        disabled: no
        enabled: yes
        action: 'default'
