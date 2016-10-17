/*
    context =
        ok: true/false login ok
        err: true/false login err
        user:
            name: user name
            passwd: user password
*/

require! 'aea': {check-login, sleep, pack}
require! \cradle
require! 'randomstring':random
charlist = "abcdefghijkmnprstxyz" + "ABCDEFGHJKLMNPRSTXYZ" + "23456789"

component-name = "login"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        __ = @
        username-input = $ @find \.username-input
        password-input = $ @find \.password-input
        error-box = $ @find \.alert.alert-danger
        login-button = @find-component \ack-button
        enter-key = 13
        checking-logged-in = $ @find \.check-state

        username-input.on \keypress, (key) ->
            if key.key-code is enter-key
                password-input.focus!

        password-input.on \keypress, (key) ->
            if key.key-code is enter-key
                login-button.fire \click

        error-box.hide!



        @on do
            do-login: (e) ->
                __ = @
                # setup db
                db-opts =
                    cache: no
                    raw: no
                    force-save: yes
                    retries: 3
                    retryTimeout: 30_000ms

                e.component.fire \state, \doing
                user = __.get \context ._user
                unless user
                    return e.component.fire \state, \error, "Kullanıcı adı/şifre boş olamaz!"

                db-opts.auth =
                    username: user.name
                    password: user.password

                c = new(cradle.Connection) "https://demeter.cloudant.com", 443, db-opts
                cc = new(cradle.Connection) "https://demeter.cloudant.com", 443, db-opts
                userdb = cc.database(\_users)

                db = c.database \domates
                db.gen-entry-id = ->
                    timestamp = new Date!get-time! .to-string 16
                    "#{timestamp}.#{random.generate {charlist: charlist, length: 4}}"


                get-credentials = (callback) ->
                    unless user.name is \demeter
                        err, res <- userdb.get "org.couchdb.user:#{user.name}"
                        if err
                            console.error err
                            e.component.fire \state, \error, err.message
                            __.set \context.err.msg, err.message
                            error-box.show!
                            return
                        callback res
                    else
                        res =
                            user: \demeter
                            roles:
                                \admin
                                ...
                        callback res

                res <- get-credentials
                
                context =
                    ok: yes
                    err: null
                    user: res

                # FIXME: workaround for not being login via cookie
                #username-input.val ''
                #password-input.val ''

                __.set \db, db
                __.set \context, context
                __.fire \success
                e.component.fire \state, \done...

            close-alert: (x) ->
                error-box.hide!

            do-logout: (e) ->
                __ = @
                e.component.fire \state, \doing
                #console.log "LOGIN: Logging out!"

                # FIXME: workaround for not being login via cookie
                username-input.val ''
                password-input.val ''

                err, res <- __.get \db .logout!
                #console.log "LOGIN: Logged out: err: #{err}, res: ", res
                if err
                    e.component.fire \state, \error, err.message
                    __.set \context.err err
                    return

                if res.ok
                    __.set \context.ok, no
                    __.fire \logout
                    e.component.fire \state, \done...

            logout: ->
                console.log "LOGIN: We are logged out..."

    data:
        context: null
        db: null
        username-placeholder: \Username
        password-placeholder: \Password
