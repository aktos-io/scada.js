require! 'dcs/browser': {find-actor, topic-match}
require! 'aea': {sleep, pack, logger, merge}

log = new logger "login-button"

can-see = (topic) ->
    perm = @get \login.permissions
    if topic `topic-match` perm.ro
        return yes
    if topic `topic-match` perm.rw
        return yes
    return no

helpers = Ractive.defaults.data
helpers.can-see = (topic)-> can-see.call this, topic
helpers.is-disabled-for = (topic) -> not can-see.call this, topic


Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('login-button.pug')
    onrender: ->
        <~ sleep 10ms
        connector = null
        @observe \transport-id, (transport-id) ->
            connector := find-actor transport-id

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
                        @fire \doLogout
                    else
                        <~ ev.component?.fire \error, "unexpected response on login: #{pack res}"

            do-logout: (ev) ->
                log.log "Logging out."

                cleanup = ~>
                    @set \token, null
                    @set \context, do
                        loggedin: no

                ev.component?.fire \state, \doing
                err, res <~ connector.proxy.logout
                if err
                    <~ ev.component.fire \error, "something went wrong while logging out"
                    #console.log "user pressed button on error screen. "
                    cleanup!
                else
                    if res.auth.logout is \ok
                        ev.component?.fire \state, \done...
                        #console.log "login button says: we got: ", res
                        cleanup!
                    else
                        <~ ev.component?.fire \error, "something went wrong while logging out, res: #{pack res}"
                        cleanup!

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
