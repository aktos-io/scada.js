{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep, merge} = require "aea"
random = require \randomstring

component-name = "order-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        self = @
        if (@get \id) is \will-be-random
            @set \id random.generate 7

        # column names
        col-list = @get \cols |> split ','
        @set \columnList, col-list

        # contents
        #console.log "table content", @partials.content

        db = @get \db
        gen-entry-id = @get \gen-entry-id

        do function update-table
            err, res <- db.query 'orders/getOrders', {+include_docs}
            if err
                console.log "ERROR: order table: ", err
            else
                console.log "Updating table: ", res
                self.set \tabledata, res
                self.set \showData, [[i.doc.client, i.doc.due-date, sum [(split ' ', ..amount .0 |> parse-int) for i.doc.entries]] for i in res.rows]

        db.changes {since: 'now', +live, +include_docs}
            .on \change, (change) ->
                console.log "order-table change detected!", change
                update-table!
        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                curr-index = @get \clickedIndex
                if index is curr-index
                    console.log "Give tooltip!"
                    @fire \showModal
                @set \clickedIndex, index
                tabledata = @get \tabledata
                @set \currOrder, tabledata.rows[index].doc
                console.log "Started editing an order: ", (@get \currOrder)

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
                #tabledata = @get \tabledata
                #edited-doc = tabledata.rows[index].doc
                #console.log "editing document: ", edited-doc
                console.log "clicked to save and end editing", index
                @fire \endEditing

            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            revert: ->
                alert "Changes Reverted!"

            show-modal: ->
                id = @get \id
                console.log "My id: ", id
                $ "\##{id}-modal" .modal \show

            add-new-order: ->
                @set \addingNew, true
                @set \currOrder, (@get \newOrder)!

            add-new-order-close: ->
                @set \addingNew, false
                @fire \endEditing

            add-new-order-save: ->
                self = @
                order-doc = @get \currOrder
                console.log "Saving new order document: ", order-doc
                if not order-doc._id?
                    console.log "Generating new id for the document!"
                    order-doc = order-doc `merge` {_id: gen-entry-id!}
                err, res <- db.put order-doc
                if err
                    console.log "Error putting new order: ", err
                else
                    console.log "New order put in the database", res
                    order-doc._rev = res.rev
                    console.log "Updating current order document rev: ", order-doc._rev
                    self.set \currOrder, order-doc

            add-new-entry: ->
                editing-doc = @get \currOrder
                console.log "adding new entry to the order: ", editing-doc
                editing-doc.entries ++= entry =
                    * type: "Type of order..."
                      amount: "amount of order..."
                    ...
                console.log "adding new entry: ", editing-doc
                @set \currOrder, editing-doc

            delete-order: (index) ->
                console.log "Delete index: ", index
                editing-doc = @get \currOrder
                editing-doc.entries.splice index, 1
                console.log "editing doc: (deleted: )", editing-doc.entries
                @set \currOrder, editing-doc


    data: ->
        new-order: ->
            client: "test..."
            type: \order
            entries:
                * type: 'tip...'
                  amount: 'x kg'
                ...
        curr-order: null
        id: \will-be-random
        gen-entry-id: null
        db: null
        tabledata: null
        show-data:
            <[ col1 col2 col3 ]>
            <[ col11 col22 col33 ]>
        editable: false
        clicked-index: null
        cols: null
        column-list: null
        editTooltip: no
        addingNew: no
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)
