require! components
require! 'aea': {PouchDB, signup}


db = new PouchDB 'https://demeter.cloudant.com/_users', {skip-setup: yes}
local = new PouchDB \local_db
product-db = new PouchDB 'https://demeter.cloudant.com/cicimeze', {skip-setup: yes}

# Ractive definition
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        login:
            ok: no
            _user:
                name: \demeter
                password: \hPwZLjgITAlqk
        db: db
        product-db: product-db
        design-document:
            _id: '_design/test'
            livescript: null
            javascript: null


feed = null
ractive.on do
    add-user: ->
        new-user = @get \newUser
        console.log "Adding user!", new-user?.name
        new-user.roles = new-user.roles?.split ','
        # admin should already be logged in `_users` database
        err, res <- signup db, new-user
        if not err
            console.log "Successfully added new user: ", new-user.name
        else
            console.log "ERROR: Adding new user: ", err

    'login.success': ->
        # Subscribe the changes...
        feed?.cancel!
        feed := local?.sync product-db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
