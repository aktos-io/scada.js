require! components
require! {
    'aea': {
        PouchDB, signup, make-design-doc
        sleep
        merge
        pack, unpack
    }
}
require! 'livescript': lsc


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
        users-auth:
            livescript: ''
            javascript: ''


db = new PouchDB 'https://demeter.cloudant.com/_users', skip-setup: yes
local = new PouchDB \local_db
ractive.set \db, db

get-auth-document = ->
    # get the _auth design document
    err, res <- db.get '_design/_auth'
    users-auth =
        _id: '_design/_auth'

    if err
        # put a new design document
        console.log "Putting a new _auth document..."
        err, res <- db.put users-auth

        if err
            console.log "Error putting design document: ", err
        else
            console.log "Design document uploaded successfully...", res
    else
        console.log "Current _auth document: ", res
        auth = res
        auth.livescript = res.src
        ractive.set \usersAuth, auth



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
        # admin should already be logged in `_users` database
        err, res <- signup db, new-user.name, new-user.passwd
        if not err
            console.log "Successfully added new user: ", new-user.name
        else
            console.log "ERROR: Adding new user: ", err

    compileAuthDocument: (callback) ->
        console.log "Compiling auth document..."
        try
            js = lsc.compile (@get \usersAuth.livescript), {+bare, -header}
            console.log "Compiled output: ", js
        catch
            js = e.to-string!
        @set \usersAuth.javascript, js

        callback! if typeof! callback is \Function

    putAuthDocument: ->
        console.log "Putting auth document!"
        # <- ractive.fire \compileAuthDocument
        console.log "Uploading auth document..."
        auth = ractive.get \usersAuth
        design-doc = eval auth.javascript
        # convert special functions to strings
        console.log "json document: ", design-doc
        auth = auth `merge` design-doc
        auth.src = auth.livescript
        auth = make-design-doc auth
        console.log "Full document to upload: ", auth
        err, res <- db.put auth
        if err
            console.log "Error uploading auth document: ", err
        else
            console.log "Auth document uploaded successfully"
        # update _rev field for the following updates
        get-auth-document!




# check whether we are logged in or not
feed = null
do function after-logged-in
    console.log "RUNNING AFTER_LOGGED_IN..."

    err, res <- db.info
    console.log "DB info: ", err, res

    err, res <- db.get-session
    console.log "Session info: ", err, res
    return if err

    # Set ractive login variable
    ractive.set \login, {user: res.userCtx, +ok}

    # Subscribe the changes...
    feed?.cancel!
    feed := local.sync db, {+live, +retry, since: \now}
        .on \error, -> feed.cancel!
        .on 'change', (change) ->
            console.log "change detected!", change

    get-auth-document!
