/*
    context =
        ok: true/false login ok
        err: true/false login err
        user:
            name: user name
            passwd: user password
*/

require! 'aea': {check-login, sleep}

component-name = "login"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    oninit: ->
        __ = @
        @on do
            do-login: ->
                __ = @
                db = @get \db
                user = __.get \context ._user
                ajax-opts = ajax: headers:
                    Authorization: "Basic #{window.btoa user.name + ':' + user.password}"
                #console.log "LOGIN: Logging in with #{user.name} and #{user.password}"
                err, res <- db.login user.name, user.password, ajax-opts
                if err
                    #console.log "LOGIN: Error while logging in: ", err
                    __.set \context.err, {msg: err.message}
                else
                    #console.log "LOGIN: Seems logged in succesfully: ", res
                    __.set \context.err, null
                    __.fire \success

            do-logout: ->
                __ = @
                db = @get \db
                #console.log "LOGIN: Logging out!"
                err, res <- db.logout!
                #console.log "LOGIN: Logged out: err: #{err}, res: ", res
                __.set \context.ok, no if res?.ok
                __.set \context.err err if err
                __.fire \logout

            logout: ->
                console.log "LOGIN: We are logged out..."

            success: ->
                #console.log "LOGIN: Login component success... "
                db = @get \db
                __ = @
                err, res <- db.get-session
                try
                    throw if res.user-ctx.name is null
                    __.set \context.ok, yes
                    __.set \context.err, null
                    __.set \context.user, res.user-ctx
                catch
                    #console.log "LOGIN: not logged in, returning: ", e
                    __.set \context.ok, no

        # check whether we are logged in
        <- sleep 200ms
        check-login (__.get \db), (err) ->
            if not err
                console.log "Login component says: we are logged in..."
                __.fire \success
            else
                console.log "Login component says: we are not logged in!"

    data:
        context: null
        db: null
