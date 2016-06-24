{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
sleep = (ms, f) -> set-timeout f, ms



ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null
        materials: []

user-id = 5

get-new-id = ->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"



products =
    _id: get-new-id!
    title: \products
    product-list:
        * name: \
          unit: \piece
          best-served: \cold
        * name: \water
          unit: \kg
          best-served: \hot


update-view = (...x) ->
    console.log "Change detected! : ", x
    db.allDocs {include_docs: true, descending: true}, (err, doc) ->
        console.log "Docs: ", doc

db = new PouchDB \mydb
#remote = 'https://USERNAME:PASSWORD@USERNAME.cloudant.com/DB_NAME'
opts =
    live: yes
    ...


db.replicate.to remote, opts
db.replicate.from remote, opts


# ------------------- Database definition ends here ----------------------#

get-materials = ->
    db.query 'primitives/raw-material-list', (err, res) ->
        console.log "this document contains raw material list: ", res
        material-document = res.rows.0.id
        db.get material-document, (err, res) ->
            materials =  [..name for res.contents]
            console.log "these are materials: ", materials
            ractive.set \materials, materials


db.changes!.on 'change',  ->
    console.log "change detected!"
    get-materials!



db.info (...x) ->
    console.log "info ::: ", x

db.query 'getTitles/new-view', (err, res) ->
    console.log "getting titles: ", res

raw-material-list = null

db.put products, (err, result) ->
    if not err
        console.log "success!"
    console.log "result: ", result
