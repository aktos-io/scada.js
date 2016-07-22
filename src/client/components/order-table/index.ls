{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep, merge, pack, unpack} = require "aea"
random = require \randomstring

component-name = "order-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        if (@get \id) is \will-be-random
            @set \id random.generate 7

        settings = @get \settings
        console.log "ORDER_TABLE: got .............. settings: ", settings
        try
            col-names = split ',' settings.col-names
            @set \columnList, col-names
        catch
            console.log "ORDER_TABLE:", "can not get col-names", e
        db = @get \db
        gen-entry-id = @get \gen-entry-id
        @set \dataFilters, settings.filters

        do function update-table
            err, res <- db.query (__.get \view), {+include_docs}
            if err
                console.log "ERROR: order table: ", err
            else
                docs = [..doc for res.rows]
                #console.log "Updating table: ", docs
                __.set \tabledata, docs

        db.changes {since: 'now', +live, +include_docs}
            .on \change, (change) ->
                #console.log "order-table change detected!", change
                update-table!


        do function create-view param
            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            try
                throw "table data is empty" if typeof! tabledata isnt \Array
                filter = filters[selected-filter]
                filtered = filter.apply __, [tabledata, param] if typeof filter is \function
                if typeof settings.after-filter is \function
                    console.log "ORDER_TABLE: applying after-filter: ", settings.after-filter
                    settings.after-filter.apply __, [filtered, (view) -> __.set \tableview, view]
                else
                    console.log "after-filter is not defined?"
            catch
                console.log "Error getting filtered: ", e, tabledata
                null

        @observe \tabledata, ->
            console.log "ORDER_TABLE: observing tabledata..."
            create-view!
        @observe \selectedFilter, ->
            console.log "ORDER_TABLE: observing selectedFilter..."
            create-view!

        @on events =
            clicked: (args) ->
                context = args.context
                index = context.id
                console.log "ORDER_TABLE: clicked!!!", args, index

                @set \clickedIndex, index
                tabledata = @get \tabledata
                @set \curr, [.. for tabledata when .._id is index].0
                #console.log "Started editing an order: ", (@get \curr)

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

            add-new-order: ->
                @set \addingNew, true
                @set \curr, (@get \newOrder)!
                console.log "adding brand-new order!", (@get \curr)

            new-order-close: ->
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
                    <- sleep 3000ms
                    __.set \saving, ''

            add-new-entry: (keypath) ->
                __ = @
                editing-doc = __.get \curr
                console.log "adding new entry to the order: ", editing-doc
                entry-template = __.get \settings.default [keypath]
                editing-doc[keypath] ++= entry-template[keypath].0

                #console.log "adding new entry: ", editing-doc
                __.set \curr, editing-doc

            delete-order: (index-str) ->
                [key, index] = split ':' index-str
                index = parse-int index
                console.log "ORDER_TABLE: delete ..#{key}.#{index}"
                editing-doc = @get \curr
                editing-doc[key].splice index, 1
                console.log "editing doc: (deleted: )", editing-doc.entries
                @set \curr, editing-doc

            run-handler: (params) ->
                handlers = settings.handlers
                handler = params  # maybe we want to run a handler without parameter
                param = null
                [handler, ...param] = params if typeof! params is \Array
                console.log "running handler with params: ", param

                handlers[handler].apply @, param if typeof handlers[handler] is \function

            set-filter: (filter-name) ->
                # this event handler is to be used in template
                @set \selectedFilter, filter-name


    data: ->
        __ = @
        instance: @
        new-order: ->
            console.log "Returning new default value: ", __.get \settings.default
            unpack pack __.get \settings.default
        saving: ''
        curr: null
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
        view-func: null
        data-filters: {}
        selected-filter: \all

        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index
