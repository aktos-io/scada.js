{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep, merge} = require "aea"
random = require \randomstring

component-name = "order-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        if (@get \id) is \will-be-random
            # then make it random
            @set \id random.generate 7
            #console.log "Table id is automatically generated: ", @get \id
        col-list = @get \cols |> split ','
        @set \columnList, col-list
        self = @
        #console.log "table content", @partials.content
        db = @get \db
        gen-entry-id = @get \gen-entry-id
        console.log "db", typeof! db
        db.changes {since: 'now', +live, +include_docs}
            .on \change, (change) ->
                console.log "order-table change detected!", change
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
                @get \db .put line, (err, res) ->
                    if err
                        console.log "ERR: Table:", err
                    else
                        console.log "INFO: Table: ", res
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

            add-new-order: ->
                @set \addingNew, true

            add-new-order-close: ->
                @set \addingNew, false

            add-new-order-save: ->
                new-order = @get \newOrder
                order-doc = new-order `merge` {_id: gen-entry-id!}
                console.log "new order document: ", order-doc
                err, res <- db.put order-doc
                if err
                    console.log "Error putting new order: ", err
                else
                    console.log "New order put in the database", res

            add-new-entry: ->
                new-order = @get \newOrder
                console.log "new order: ", new-order
                new-order.entries ++= entry =
                    * type: "Type of order..."
                      amount: "amount of order..."
                    ...
                @set \newOrder, new-order

            delete-order: (index) ->
                console.log "Delete index: ", index
                new-order = @get \newOrder
                new-order.entries.splice index, 1
                console.log "new order (deleted: )", new-order.entries
                @set \newOrder, new-order


    data: ->
        new-order:
            client: "test..."
            entries: []
        id: \will-be-random
        gen-entry-id: null
        db: null
        tabledata: null
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
