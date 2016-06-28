{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
sleep = (ms, f) -> set-timeout f, ms

db = null

InteractiveTable = Ractive.extend do
    oninit: ->
        col-list = @get \cols |> split ','
        @set \columnList, col-list
        self = @
        console.log "table content", @get \content

        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                curr-index = @get \clickedIndex
                if index is curr-index
                    console.log "Give tooltip!"
                    @fire \showModal
                @set \clickedIndex, index

            close-modal: ->
                self = @
                $ "\##{@get 'id'}-modal" .modal \hide
                <- sleep 300ms
                self.fire \giveTooltip


            give-tooltip: ->
                self = @
                i = 0
                <- :lo(op) ->
                    <- sleep 150ms
                    self.set \editTooltip, on
                    <- sleep 150ms
                    self.set \editTooltip, off
                    if ++i is 2
                        return op!
                    lo(op)


            save-and-exit: ->
                index = @get \clickedIndex
                console.log "clicked to save and hide", index
                line = (@get \tabledata)[index]
                #console.log "line is: ", line
                db.put line
                @set \clickedIndex, null
                @set \editable, no

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            revert: ->
                alert "Changes Reverted!"

            show-modal: ->
                id = @get \id
                console.log "My id: ", id
                $ "\##{id}-modal" .modal \show

    template: '#interactive-table'
    data:
        tabledata: []
        editable: false
        clicked-index: null
        cols: null
        column-list: null
        editTooltip: no
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)



db = null
satis-listesi = null


ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null
        materials: []
        new-sales: {}
        sales-entries: []
        sales-to-table: (sales-data) ->
            [[..name, ..date] for sales-data]
    components:
        'interactive-table': InteractiveTable

generate-entry-id = (user-id) -> ->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"

get-entry-id = generate-entry-id 5
console.log "get entry id: ", get-entry-id


ractive.on do
    update-table: ->
        console.log "updating satis listesi!", satis-listesi
        db.put satis-listesi, (err, res) ->
            console.log "satıs listesi (put): ", err, res
        <- sleep 1000ms
        console.log "satis-listesi: :: ", satis-listesi

    add-sales-entry: ->
        new-sales = ractive.get \newSales
        new-sales.rel = "sales"
        new-sales._id = get-entry-id!
        console.log "putting new-sales: ", new-sales
        db.put new-sales, (err, res) ->
            if not err
                console.log "New sales entry is added successfully: ", res

db = new PouchDB \mydb
#remote = 'https://USERNAME:PASSWORD@USERNAME.cloudant.com/DB_NAME'
db.sync remote, {live: yes}

# ------------------- Database definition ends here ----------------------#


get-materials = ->
    db.query 'primitives/raw-material-list', (err, res) ->
        console.log "this document contains raw material list: ", res
        material-document = res.rows.0.id
        db.get material-document, (err, res) ->
            materials =  [..name for res.contents]
            console.log "these are materials: ", materials
            ractive.set \materials, materials



/*
db.info (err, res) ->
    console.log "info ::: ", x
*/

db.query 'getTitles/new-view', (err, res) ->
    try
        throw if err
        console.log "getting titles: ", res
        db.all-docs {include_docs: yes, keys: [..key for res.rows]}, (err, res) ->
            console.log "documents related with titles: ", err, res
    catch
        console.log "can not get new view: ", err


# get all sales entries and set ractive's appropriate property
get-sales-entries = ->
    db.query 'get-by-type/get-sales', (err, res) ->
        try
            throw err if err
            console.log "got sales entries: "
            db.all-docs {include_docs: yes, keys: [..key for res.rows]}, (err, res) ->
                console.log "sales entries: ", err, res
                ractive.set "salesEntries", [..doc for res.rows]
        catch
            console.log "error: ", e

get-sales-entries!

db.changes {since: \now, live: yes} .on 'change', (change) ->
    console.log "change detected!", change
    get-materials!
    get-sales-entries!
