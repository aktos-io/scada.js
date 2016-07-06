require! {
    'aea': {
        signup
        PouchDB
        sleep
    }
    './components': {
        InteractiveTable
    }
}

Ractive.components['interactive-table'] = InteractiveTable

# Ractive definition
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        login:
            err: null
            ok: no
            user: null
            new-user: null
        db: \set-later
        user:
            name: \demeter
            passwd: \hPwZLjgITAlqk


db = new PouchDB 'https://demeter.cloudant.com/_users', skip-setup: yes
local = new PouchDB \local_db
ractive.set \db, db

after-logged-in = null

ractive.on do
    do-login: ->
        user = ractive.get \user
        ajax-opts = ajax: headers:
            Authorization: "Basic #{window.btoa user.name + ':' + user.passwd}"
        console.log "Logging in with #{user.name} and #{user.passwd}"
        err, res <- db.login user.name, user.passwd, ajax-opts
        if err
            console.log "Error while logging in: ", err
            ractive.set \login.err, {msg: err.message}
        else
            console.log "Logged  in: ", res
            err, res <- db.get-session
            console.log "Session: ", err, res.userCtx
            if res.userCtx.name
                ractive.set \login.err, null
                ractive.set \login.ok, yes
                after-logged-in!
    do-logout: ->
        console.log "Logging out!"
        err, res <- db.logout!
        console.log "Logged out: err: #{err}, res: ", res
        ractive.set \login.ok, null if res.ok

    add-user: ->
        new-user = @get \newUser
        console.log "Adding user!", new-user?.name

        #demeter:hPwZLjgITAlqk

        # admin should already be logged in `_users` database
        err, res <- signup db, new-user.name, new-user.passwd
        if not err
            console.log "Successfully added new user: ", new-user.name

        else
            console.log "ERROR: Adding new user: ", err

do # check whether we are logged in or not
    feed = null
    do after-logged-in := ->
        err, res <- db.info
        console.log "Error: ", err if err
        throw err if err?.status isnt 200
        feed?.cancel!
        feed := local.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                get-materials!
                get-sales-entries!

        db.get-session (err, res) ->
            ractive.set \login, {user: res.userCtx, +ok}

        # add a design document to
