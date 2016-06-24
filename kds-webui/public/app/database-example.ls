{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
sleep = (ms, f) -> set-timeout f, ms



ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null

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
    continuous: yes
    on-change: update-view

db.replicate.to remote, opts
db.replicate.from remote, opts


db.info (...x) ->
    console.log "info ::: ", x

db.query 'getTitles/new-view', (err, res) ->
    console.log "getting titles: ", res

db.put products, (err, result) ->
    if not err
        console.log "success!"
    console.log "result: ", result
