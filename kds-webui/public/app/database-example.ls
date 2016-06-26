{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
sleep = (ms, f) -> set-timeout f, ms


db = null
satis-listesi = null

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null
        materials: []

ractive.on do
    update-table: ->
        console.log "updating satis listesi!", satis-listesi
        db.put satis-listesi, (err, res) ->
            console.log "satıs listesi (put): ", err, res
        <- sleep 1000ms
        console.log "satis-listesi: :: ", satis-listesi

db = new PouchDB \mydb
#remote = 'https://USERNAME:PASSWORD@USERNAME.cloudant.com/DB_NAME'

db.sync remote, {live: yes}

# ------------------- Database definition ends here ----------------------#

get-new-id = (user-id) -->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"

default-entry-id = get-new-id 5


get-materials = ->
    db.query 'primitives/raw-material-list', (err, res) ->
        console.log "this document contains raw material list: ", res
        material-document = res.rows.0.id
        db.get material-document, (err, res) ->
            materials =  [..name for res.contents]
            console.log "these are materials: ", materials
            ractive.set \materials, materials


opts =
    since: 'now'
    live: true

db.changes opts .on 'change', (...x) ->
    console.log "change detected!", x
    get-materials!

db.info (...x) ->
    console.log "info ::: ", x

db.query 'getTitles/new-view', (err, res) ->
    console.log "getting titles: ", res
    db.all-docs {include_docs: yes, keys: [..key for res.rows]}, (err, res) ->
        console.log "documents related with titles: ", err, res


db.get "satış listesi", (err, res) ->
    satis-listesi := res
    console.log "satış listesi: ", satis-listesi
    ractive.set "myTableData", satis-listesi.entries
