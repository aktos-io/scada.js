require! 'dcs/browser': {find-actor, topic-match}
require! 'aea': {sleep, pack, logger, merge}

log = new logger "login-button"

# Permission calculation mechanism
helpers = Ractive.defaults.data
helpers.can-see = (login, topic) ~>
    try
        permissions = login.permissions
        console.log "known permissions: ", permissions
        if permissions
            for perm in permissions.ro ++ permissions.rw
                if topic `topic-match` perm
                    return yes
        return no
    catch
        console.error "hey, error in can-see: ", e
        return no


helpers.can-write = (login, topic) ~>
    try
        permissions = login.permissions
        console.log "known permissions: ", permissions
        if permissions
            for perm in permissions.rw
                if topic `topic-match` perm
                    return yes
        return no
    catch
        console.error "hey, error in can-write: ", e
        return no

helpers.cannot-see = (...args) ~> not helpers.can-see.apply this, args
helpers.cannot-write = (...args) ~> not helpers.can-write.apply this, args

Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('login-button.pug')
    onrender: ->
        <~ sleep 10ms
        connector = null
        @observe \transport-id, (transport-id) ->
            connector := find-actor transport-id

        set-logout-variables = ~>
            @set \token, null
            @set \context, do
                loggedin: no

        @on do
            click: ->
                @find-component 'ack-button' .fire \buttonclick

            do-login: (ev) ->
                ev.component?.fire \state, \doing

                unless connector
                    console.error "There is no connector actor found: ", connector

                user = @get \user
                password = @get \password
                token = @get \token

                if user and password
                    credentials =
                        user: user
                        password: password
                else if token
                    credentials =
                        token: token
                else
                    ev.component?.fire \error, "no credentials given"
                    return

                log.log "Trying to login with credentials..."
                err, res <~ connector.proxy.login credentials

                if err
                    <~ ev.component?.fire \error, "something went wrong with login: #{pack err}"
                else
                    if res.auth.error
                        ev.component?.fire \error, pack(that)
                    else if res.auth.session.token
                        ev.component?.fire \state, \done...
                        # calculate context
                        context = res.auth.session <<< do
                            loggedin: yes

                        # set context
                        @set \context, context

                        # set 'token' explicitly to save in the persistent browser storage
                        @set \token, context.token

                        @fire \success

                    else if res.auth.session.logout is \yes
                        log.log "Will log out..."
                        set-logout-variables!
                    else
                        <~ ev.component?.fire \error, "unexpected response on login: #{pack res}"

            do-logout: (ev) ->
                log.log "Logging out."

                ev.component?.fire \state, \doing
                err, res <~ connector.proxy.logout
                if err
                    <~ ev.component.fire \error, "something went wrong while logging out"
                    #console.log "user pressed button on error screen. "
                    set-logout-variables!
                else
                    if res.auth.logout is \ok
                        ev.component?.fire \state, \done...
                        #console.log "login button says: we got: ", res
                        set-logout-variables!
                    else
                        <~ ev.component?.fire \error, "something went wrong while logging out, res: #{pack res}"
                        set-logout-variables!

            do-action: (ev) ->
                if @get \logout
                    @fire \doLogout, ev
                else
                    @fire \doLogin, ev

        if @get \auto
            #log.log "Performing auto clicking"
            @fire \doLogin

    data: ->
        loggedin: no
        disabled: no
        enabled: yes
        action: 'default'
