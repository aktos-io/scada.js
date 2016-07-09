require! components
require! {
    'aea': {
        PouchDB
    }
}

# Ractive definition
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null
        materials: []
        new-sales: {}
        user: {}
        sales-entries: []
        login:
            err: null
            ok: no
            user: null
        mydb: \will-be-set-later
        sales-to-table: (sales-data) ->
            [[..name, ..date] for sales-data]


satis-listesi = null

generate-entry-id = (user-id) -> ->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"

get-entry-id = generate-entry-id 5

after-logged-in = null
db = new PouchDB 'https://demeter.cloudant.com/cicimeze', skip-setup: yes
local = new PouchDB \local_db
ractive.set \mydb, db
# ------------------- Database definition ends here ----------------------#

ractive.on do
    update-table: ->
        console.log "updating satis listesi!", satis-listesi
        db.put satis-listesi, (err, res) ->
            console.log "satıs listesi (put): ", err, res
        console.log "satis-listesi: :: ", satis-listesi

    add-sales-entry: ->
        new-sales = ractive.get \newSales
        new-sales.rel = "sales"
        new-sales._id = get-entry-id!
        console.log "putting new-sales: ", new-sales
        db.put new-sales, (err, res) ->
            try
                throw err if err
                console.log "New sales entry is added successfully: ", res
            catch
                console.log "Could not add sales entry: ", e

    do-login: ->
        user = @get \user
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


# check whether we are logged in or not
feed = null
do after-logged-in := ->
    err, res <- db.info
    console.log "Error getting info: ", err if err
    throw err if err?.status isnt 200
    console.log "hele hele "
    err, res <- db.get-session
    console.log "Session: ", err, res.userCtx

    feed?.cancel!
    feed := local.sync db, {+live, +retry, since: \now}
        .on \error, -> feed.cancel!
        .on 'change', (change) ->
            console.log "change detected!", change
            get-materials!
            get-sales-entries!

    db.get-session (err, res) ->
        ractive.set \login, {user: res.userCtx, +ok}

    get-materials = ->
        db.query 'primitives/raw-material-list', (err, res) ->
            console.log "this document contains raw material list: ", res
            material-document = res.rows.0.id
            db.get material-document, (err, res) ->
                materials =  [..name for res.contents]
                console.log "these are materials: ", materials
                ractive.set \materials, materials

    # get all sales entries and set ractive's appropriate property
    do get-sales-entries = ->
        console.log "getting sales entries!"
        db.query 'get-by-type/get-sales', (err, res) ->
            try
                throw err if err
                console.log "got sales entry id's, fetching data..."
                db.all-docs {include_docs: yes, keys: [..key for res.rows]}, (err, res) ->
                    console.log "sales entries: ", err, res
                    ractive.set "salesEntries", [..doc for res.rows]
            catch
                console.log "error: ", e
