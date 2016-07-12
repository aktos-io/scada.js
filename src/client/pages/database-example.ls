require! components
require! {
    'aea': {
        PouchDB
    }
}

db = new PouchDB 'https://demeter.cloudant.com/cicimeze', skip-setup: yes
local = new PouchDB \local_db

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
        db: db
        sales-to-table: (sales-data) ->
            [[..name, ..date] for sales-data]


satis-listesi = null

generate-entry-id = (user-id) -> ->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"

get-entry-id = generate-entry-id 5

# ------------------- Database definition ends here ----------------------#

feed = null
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

    after-logged-in: ->
        do function on-change
            console.log "running function on-change!"
            get-materials!
            get-sales-entries!

        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                try
                    on-change!
                catch
                    console.log "nedir?", e

function get-materials
    db.query 'primitives/raw-material-list', (err, res) ->
        console.log "this document contains raw material list: ", res
        material-document = res.rows.0.id
        db.get material-document, (err, res) ->
            materials =  [..name for res.contents]
            console.log "these are materials: ", materials
            ractive.set \materials, materials

# get all sales entries and set ractive's appropriate property
function get-sales-entries
    console.log "getting sales entries!"
    db.query 'get-by-type/get-sales', {+include_docs}, (err, res) ->
        try
            throw err if err
            console.log "sales entries: ", err, res
            ractive.set "salesEntries", [..doc for res.rows]
        catch
            console.log "error: ", e
