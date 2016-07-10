require! components
require! {
    'aea': {
        PouchDB, signup, make-design-doc, check-login
        sleep
        merge
        pack, unpack
    }
    'prelude-ls': {
        join
    }
}
require! 'livescript': lsc



Ractive.components['x'] = Ractive.extend do
    template: '#x'


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
        design-document:
            _id: '_design/test'
            livescript: null
            javascript: null


db = new PouchDB 'https://demeter.cloudant.com/_users', {skip-setup: yes}
#local = new PouchDB \local_db
ractive.set \db, db
console.log "current adapter:", local?adapter


get-design-document = ->
    # get the _auth design document
    design-document = ractive.get \designDocument
    err, res <- db.get design-document._id
    if err
        console.log "Can not get design document: ", err
    else
        console.log "Current _auth document: ", res
        ddoc = res
        ddoc.livescript = res.src
        ractive.set \designDocument, ddoc

put-new-design-document = ->
    design-document = ractive.get \designDocument
    delete design-document._rev
    console.log "Putting new design document: ", design-document
    err, res <- db.put design-document
    if err
        console.log "Error putting design document: ", err
    else
        console.log "Design document uploaded successfully...", res
        get-design-document!


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
            console.log "Seems logged in succesfully: ", res
            after-logged-in!

    do-logout: ->
        console.log "Logging out!"
        err, res <- db.logout!
        console.log "Logged out: err: #{err}, res: ", res
        ractive.set \login.ok, null if res.ok

    add-user: ->
        new-user = @get \newUser
        console.log "Adding user!", new-user?.name
        new-user.roles = new-user.roles?split ','
        # admin should already be logged in `_users` database
        err, res <- signup db, new-user
        if not err
            console.log "Successfully added new user: ", new-user.name
        else
            console.log "ERROR: Adding new user: ", err

    compileDesignDocument: (callback) ->
        console.log "Compiling auth document..."
        try
            js = lsc.compile (@get \designDocument.livescript), {+bare, -header}
            console.log "Compiled output: ", js
        catch
            js = e.to-string!
        @set \designDocument.javascript, js

        callback! if typeof! callback is \Function

    putDesignDocument: ->
        console.log "Putting design document!"
        console.log "Uploading design document..."
        ddoc = ractive.get \designDocument
        ddoc-js = eval ddoc.javascript
        # convert special functions to strings
        ddoc = ddoc `merge` ddoc-js
        ddoc.src = ddoc.livescript
        ddoc = make-design-doc ddoc
        console.log "Full document to upload: ", ddoc
        err, res <- db.put ddoc
        if err
            console.log "Error uploading ddoc-src document: ", err
        else
            console.log "ddoc-src document uploaded successfully"
        # update _rev field for the following updates
        get-design-document!

    get-design-document: ->
        get-design-document!
    put-new-design-document: ->
        put-new-design-document!


# do stuff after logged in
feed = null
do function after-logged-in
    <- check-login db
    console.log "RUNNING AFTER_LOGGED_IN..."
    err, res <- db.get-session
    console.log "Session info: ", err, res
    try
        throw if res.user-ctx.name is null
    catch
        console.log "not logged in, returning..."
        ractive.set \login, {+err, -ok, user: null}
        return
    # Set ractive login variable
    ractive.set \login, {user: res.userCtx, +ok, -err}

    # Subscribe the changes...
    feed?.cancel!
    feed := local?.sync db, {+live, +retry, since: \now}
        .on \error, -> feed.cancel!
        .on 'change', (change) ->
            console.log "change detected!", change

    get-design-document!
