{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep, merge, pack, unpack} = require "aea"
random = require \randomstring

component-name = "order-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        __ = @
        if (@get \id) is \will-be-random
            @set \id random.generate 7

        # column names
        try
            col-list = split ',', @get \cols
        catch
            throw "ORDER_TABLE: Can not get cols list: #{e}"

        @set \columnList, col-list

        db = @get \db
        gen-entry-id = @get \gen-entry-id

        view-func = @get \view-func
        #console.log "ORDER_TABLE: view-func: ", view-func
        do function update-table
            err, res <- db.query (__.get \view), {+include_docs}
            if err
                console.log "ERROR: order table: ", err
            else
                console.log "Updating table: ", res
                __.set \tabledata, res
                __.set \showData, (view-func res)

        db.changes {since: 'now', +live, +include_docs}
            .on \change, (change) ->
                console.log "order-table change detected!", change
                update-table!
        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                curr-index = @get \clickedIndex
                /*
                if index is curr-index
                    #console.log "Give tooltip!"
                    #@fire \showModal
                */
                @set \clickedIndex, index
                tabledata = @get \tabledata
                @set \curr, tabledata.rows[index].doc
                console.log "Started editing an order: ", (@get \curr)

            close-modal: ->
                __ = @
                $ "\##{@get 'id'}-modal" .modal \hide
                <- sleep 300ms
                __.fire \giveTooltip


            give-tooltip: ->
                __ = @
                i = 0
                <- :lo(op) ->
                    <- sleep 150ms
                    __.set \editTooltip, on
                    <- sleep 150ms
                    __.set \editTooltip, off
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
                @set \curr, (@get \newOrder)!
                console.log "adding brand-new order!", (@get \curr)

            add-new-order-close: ->
                console.log "ORDER_TABLE: Closing edit form..."
                @set \addingNew, false
                @fire \endEditing

            add-new-order-save: ->
                __ = @
                order-doc = @get \curr

                __.set \saving, "Kaydediyor..."
                console.log "Saving new order document: ", order-doc
                if not order-doc._id?
                    console.log "Generating new id for the document!"
                    order-doc = order-doc `merge` {_id: gen-entry-id!}

                err, res <- db.put order-doc
                if err
                    console.log "Error putting new order: ", err
                    __.set \saving, err.reason
                else
                    console.log "New order put in the database", res
                    # if adding new document, clean up current document
                    console.log "order putting database: ", order-doc
                    if order-doc._rev is void
                        console.log "refreshing new order...."
                        __.set \curr, (__.get \newOrder)!
                    else
                        console.log "order had rev: ", order-doc._rev
                        order-doc._rev = res.rev
                        console.log "Updating current order document rev: ", order-doc._rev
                        __.set \curr, order-doc
                    __.set \saving, "OK!"
                    <- sleep 1000ms
                    __.set \saving, ''

            add-new-entry: (keypath) ->
                __ = @
                editing-doc = __.get \curr
                console.log "adding new entry to the order: ", editing-doc
                entry-template = __.get \default [keypath]
                editing-doc[keypath] ++= entry-template[keypath].0

                #console.log "adding new entry: ", editing-doc
                __.set \curr, editing-doc

            delete-order: (index-str) ->
                [key, index] = split ':', index-str
                index = parse-int index
                console.log "ORDER_TABLE: delete ..#{key}.#{index}"
                editing-doc = @get \curr
                editing-doc[key].splice index, 1
                console.log "editing doc: (deleted: )", editing-doc.entries
                @set \curr, editing-doc


    data: ->
        __ = @
        new-order: ->
            console.log "Returning new default value: ", __.get \default
            unpack pack __.get \default
        saving: ''
        curr: null
        id: \will-be-random
        gen-entry-id: null
        db: null
        tabledata: null
        show-data:
            <[ default1 default2 default3 ]>
            <[ default11 default22 default33 ]>
            <[ default111 default222 default333 ]>
        editable: false
        clicked-index: null
        cols: null
        column-list: null
        editTooltip: no
        addingNew: no
        view-func: null
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index
