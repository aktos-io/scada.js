require! 'prelude-ls': {
    split, take, join, lists-to-obj, sum, filter
    camelize, find
}
require! 'aea': {sleep, merge, pack, unpack}
require! 'randomstring': random

component-name = "data-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        db = @get \db
        console.error "No database object is passed to data-table!" unless db

        if (@get \id) is \will-be-random
            # then make it random
            @set \id random.generate 7

        settings = @get \settings

        if typeof! settings isnt \Object
            console.log "No settings found!"
            return

        try
            col-list = split ',', settings.col-names
            @set \columnList, col-list
        catch
            console.warn "DATA_TABLE: problem with col-names: ", e
            return

        handlers = {}
        for handler, func of settings.handlers
            handlers[handler] = func.bind this

        @set \handlers, handlers

        gen-entry-id = db.gen-entry-id

        @set \readonly, if @partials.editForm
            no
        else
            yes

        @set \dataFilters, settings.filters

        @observe \tabledata, create-view = ->
            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            try
                throw if tabledata.length is 0
            catch
                return

            unless typeof settings.after-filter is \function
                console.error "after-filter is not defined?", settings.col-names
                return

            ffunc = filters[selected-filter]
            filtered = ffunc.apply __, [tabledata] if typeof ffunc is \function
            generate-visible = (view) ->
                try
                    __.set \tableview, view
                    if settings.page-size > 0
                        curr-page = __.get \currPage
                        min = (x, y) -> if x < y then x else y
                        items =
                            from: curr-page * settings.page-size
                            to: min ((curr-page + 1) * settings.page-size) - 1, (view.length - 1)

                        __.set \tableview_visible, [.. for view when items.from <= ..no <= items.to ]
                    else
                        __.set \tableview_visible, view
                catch
                    debugger

            unless filtered
                console.warn "Filtered data is undefined! "
            else
                settings.after-filter.apply __, [filtered, generate-visible]


        @set \create-view, create-view


        try
            throw "on-change is not a function!" if typeof settings.on-change isnt \function
            do on-change = ->
                settings.on-change.apply __
        catch
            #console.log "DATA TABLE: INFO: ", e

        @observe \changes, ->
            if typeof on-change is \function
                #if settings.debug then console.log "DATA_TABLE: ON-CHANGE IS FUNCTION..."
                on-change!
            else
                create-view!

        @observe \settings.pageSize, ->
            create-view!

        # Run post init (from instance)
        try
            settings.on-init.apply this if typeof settings.on-init is \function
        catch
            console.log "ERROR FROM DATA_TABLE: on-init: ", e


        events =
            clicked: (args) ->
                context = args.context
                index = context.id
                unless (@get \clickedIndex) is index
                    # trigger only if there is a change
                    #console.log "ORDER_TABLE: clicked!!!", args, index
                    @set \clickedIndex, index
                    @set \lastIndex, index

                    tabledata = @get \tabledata
                    curr = find (._id is index), tabledata
                    if curr
                        @set \curr, curr
                    else
                        curr = index

                    settings.on-create-view.call this, curr if typeof! settings.on-create-view is \Function


            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            show-modal: ->
                id = @get \id
                console.log "My id: ", id
                $ "\##{id}-modal" .modal \show

            set-filter: (filter-name) ->
                console.log "DATA_TABLE: filter is set to #{filter-name}"
                @set \selectedFilter, filter-name if filter-name
                @set \currPage, 0
                create-view!


            select-page: (page-num) ->
                @set \currPage, page-num
                create-view!

            save-and-exit: ->
                index = @get \clickedIndex
                #tabledata = @get \tabledata
                #edited-doc = tabledata.rows[index].doc
                #console.log "editing document: ", edited-doc
                console.log "clicked to save and end editing", index
                @fire \endEditing

            add-new-order: ->
                new-order = (@get \newOrder)!
                new-order._id = gen-entry-id!

                @set \curr, new-order

                @set \addingNew, true
                #console.log "adding brand-new order!", (@get \curr)


                if typeof! settings.on-create-view is \Function
                    settings.on-create-view.call this, new-order


            new-order-close: ->
                #console.log "ORDER_TABLE: Closing edit form..."
                @set \addingNew, false
                @fire \endEditing

            save: (e) ->
                __ = @
                order-doc = @get \curr

                button-state = (state, msg) ->
                    e.component.fire \state, state, msg if e

                __.set \saving, "Kaydediyor..."
                button-state \doing

                console.log "Saving new order document: ", order-doc
                if not order-doc._id?
                    console.log "Generating new id for the document!"
                    order-doc = order-doc `merge` {_id: gen-entry-id!}

                err, res <- db.put order-doc
                if err
                    console.log "Error putting new order: ", err
                    __.set \saving, "#{__.get \saving} : #{err.message}"
                    button-state \error, err.message
                else
                    console.log "New order put in the database", res
                    # if adding new document, clean up current document
                    console.log "order putting database: ", order-doc
                    t = __.get \tabledata
                    if order-doc._id not in [.._id for t]
                        __.set \tabledata ([order-doc] ++ t)

                    if order-doc._rev is void
                        console.log "refreshing new order...."
                        __.set \curr, (__.get \newOrder)!
                    else
                        console.log "order had rev: ", order-doc._rev
                        order-doc._rev = res.rev
                        console.log "Updating current order document rev: ", order-doc._rev
                        __.set \curr, order-doc

                    __.set \saving, "OK!"
                    button-state \done...
                    # TODO: use "kick-changes! function"
                    __.set \changes, (1 + __.get \changes)

            add-new-entry: (keypath) ->
                __ = @
                editing-doc = __.get \curr
                template = unpack pack __.get "settings.default.#{keypath}.0"
                if typeof! editing-doc[keypath] isnt \Array
                    console.log "Keypath is not an array, converting to array"
                    editing-doc[keypath] = []
                editing-doc[keypath] ++= template

                console.log "adding new entry: ", template
                __.set \curr, editing-doc


            delete-order: (index-str) ->
                [key, index] = split ':' index-str
                index = parse-int index
                editing-doc = @get \curr
                editing-doc[key].splice index, 1
                @set \curr, editing-doc

        @on events `merge` handlers


    data: ->
        __ = @
        instance: @
        new-order: ->
            console.log "ORDER_TABLE: Returning new default value: ", __.get \settings.default
            try unpack pack __.get \settings.default
        curr: null
        id: \will-be-random
        readonly: no
        tabledata: []
        tableview: []
        tableview_visible: []
        editable: false
        clicked-index: null
        last-index: null
        cols: null
        column-list: null
        editTooltip: no
        addingNew: no
        view-func: null
        data-filters:
            all: (docs) -> docs
        selected-filter: \all
        curr-page: 0
        dont-watch-changes: no

        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index

        is-last-clicked: (index) ->
            x = index is @get \lastIndex

        trigger-change: ->
            __.set \dontWatchChanges, yes
            __.set \changes, (1 + __.get \changes)

        refresh: ->
            console.log "TABLE IS REFRESHING!!!"
            __.fire \setFilter, \all
            create-view = __.get \create-view
            create-view!

        range: (_from, _to) ->
            try
                range = [i for i from parse-int(_from) to parse-int(_to)]
                range
            catch
                console.log "error in range generator: ", _from, _to

        curr-view: ->
            curr = __.get \curr
            filter (.id is curr._id), __.get \tableview .0
