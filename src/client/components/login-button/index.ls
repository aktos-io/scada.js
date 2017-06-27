require! 'dcs/browser': {AuthActor}
require! 'aea': {sleep, pack}


_permissions =
    read: {}
    write: {}


helpers = Ractive.defaults.data
helpers.can-see = (topic) ->
    x = @get \permissions
    _permissions.read[topic]

helpers.is-disabled-for = (topic) ->
    x = @get \permissions
    not _permissions.write[topic]

auth = new AuthActor!


Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    oninit: ->
        @on do
            do-login: (_event) ->
                _event.component.fire \state, \doing
                err, res <~ auth.login {username: @get('username'), password: @get('password')}
                if err
                    <~ _event.component.fire \error, "something went wrong with login: #{pack err}"
                else
                    if res.auth.session.token
                        _event.component.fire \state, \done...
                        #console.log "login button says: we got: ", res
                        @set \loggedin, yes
                        # token is written to local-storage and sent to relevant actor in AuthActor
                        @fire \getPermissions, res.auth.session.permissions
                    else
                        <~ _event.component.fire \error, "unexpected response on login: #{pack res}"

            do-logout: (_event) ->
                _event.component.fire \state, \doing
                err, res <~ auth.logout
                if err
                    <~ _event.component.fire \error, "something went wrong while logging out"
                    #console.log "user pressed button on error screen. "
                else
                    if res.auth.logout is \ok
                        _event.component.fire \state, \done...
                        #console.log "login button says: we got: ", res
                        @set \loggedin, no
                        @fire \getPermissions, {ro: [], rw: []}
                    else
                        <~ _event.component.fire \error, "something went wrong while logging out, res: #{pack res}"



            do-action: (_event) ->
                if @get(\action) is \logout
                    @fire \doLogout, _event
                else
                    @fire \doLogin, _event

            get-permissions: (_event, perm) ->
                # read permissions
                #console.log "permissions: ", perm
                if typeof! perm is \Object
                    _permissions := {read: {}, write: {}}
                    if perm.ro
                        for permission in perm.ro
                            _permissions.read[permission] = yes

                    if perm.rw
                        for permission in perm.rw
                            _permissions.write[permission] = yes

                    @root.update \permissions
                else
                    console.warn "permissions are something we don't expect: ", perm
    data: ->
        loggedin: no
        disabled: no
        enabled: yes
        action: 'default'
        let-checking-session: yes

Ractive.components['check-login'] = Ractive.extend do
    template: ''
    isolated: yes
    oninit: ->
        @on do
            get-permissions: (_event, perm) ->
                # read permissions
                #console.log "permissions: ", perm
                if typeof! perm is \Object
                    _permissions := {read: {}, write: {}}
                    if perm.ro
                        for permission in perm.ro
                            _permissions.read[permission] = yes

                    if perm.rw
                        for permission in perm.rw
                            _permissions.write[permission] = yes

                    @root.update \permissions
                else
                    console.warn "permissions are something we don't expect: ", perm

        <~ sleep 300ms
        err, res <~ auth.check-session
        unless err
            if res.auth.logout is \yes
                #console.log "logging out"
                @set \loggedin, no
            else if res.auth.session
                #console.log "server says we are logged in as #{res.auth.session.user}, perms: ", res.auth.session.permissions
                @set \username, res.auth.session.user
                @set \loggedin, yes
                @fire \getPermissions, res.auth.session.permissions
            else
                console.warn "unknown response: ", res
        else
            unless err.code in <[ singleton already-checked ]>
                console.warn "something went wrong while checking the session, err: ", err
