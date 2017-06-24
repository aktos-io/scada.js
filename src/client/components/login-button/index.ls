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
                    <~ event.component.fire \error, "something went wrong with login: #{pack err}"
                    #console.log "user pressed button on error screen. "
                else
                    if res.auth.session
                        event.component.fire \state, \done...
                        #console.log "login button says: we got: ", res
                        @set \loggedin, yes
                        # token is written to local-storage and sent to relevant actor in AuthActor
                    else
                        <~ event.component.fire \error, "unexpected response on login: #{pack res}"


            do-logout: (event) ->
                event.component.fire \state, \doing
                err, res <~ @auth.logout
                if err
                    <~ event.component.fire \error, "something went wrong while logging out"
                    #console.log "user pressed button on error screen. "
                else
                    if res.auth.logout is \ok
                        event.component.fire \state, \done...
                        console.log "login button says: we got: ", res
                        @set \loggedin, no
                    else
                        <~ event.component.fire \error, "something went wrong while logging out, res: #{pack res}"



            do-action: (event) ->
                if @get(\action) is \logout
                    @fire \doLogout, event
                else
                    @fire \doLogin, event

    onrender: ->
        <~ sleep 300ms
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
