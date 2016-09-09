require! 'prelude-ls': {split, take, join, lists-to-obj, sum, filter}
require! 'aea': {sleep, merge, pack, unpack}
require! 'randomstring': random

component-name = "data-table"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        if (@get \id) is \will-be-random
            # then make it random
            @set \id random.generate 7

        # get settings
        # ------------
        # cols
        # filters: returns data in [{id: .., cols: [.....]}] format
        # tabledata: data to display, in [{_id: ..., .....}] format

        settings = @get \settings

        if typeof! settings isnt \Object
            console.log "No settings found!"
            return

        try
            col-list = split ',', settings.col-names
            @set \columnList, col-list
        catch
            console.log "DATA_TABLE: problem with col-names: ", e
            return

        db = @get \db
        gen-entry-id = @get \gen-entry-id

        @set \readonly, if @partials.editForm
            no
        else
            yes

        unless @get \readonly
            throw "GEN_ENTRY_ID: NOT FOUND!!!" if typeof! gen-entry-id isnt \Function

        @set \dataFilters, settings.filters

        do function create-view param
            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            #console.log "DATA_TABLE: Running create-view...", selected-filter if settings.debug
            try
                return if typeof! tabledata isnt \Array
                throw "tabledata empty" if tabledata.length is 0
                ffunc = filters[selected-filter]
                filtered = ffunc.apply __, [tabledata, param] if typeof ffunc is \function
                if typeof settings.after-filter is \function
                    #console.log "DATA_TABLE: applying after-filter: ", settings.after-filter if settings.debug

                    generate-visible = (view) ->
                        #console.log "orig view size: ", view.length
                        #return if view.length < 1
                        __.set \tableview, view
                        if settings.page-size > 0
                            curr-page = __.get \currPage
                            min = (x, y) -> if x < y then x else y
                            items =
                                from: curr-page * settings.page-size
                                to: min ((curr-page + 1) * settings.page-size) - 1, (view.length - 1)
                            #console.log "generating visible part, items:", items

                            __.set \tableview_visible, [.. for view when items.from <= ..no <= items.to ]
                        else
                            __.set \tableview_visible, view

                    #settings.after-filter.apply __, [filtered, (view) -> __.set \tableview, view]
                    settings.after-filter.apply __, [filtered, generate-visible]
                else
                    console.log "after-filter is not defined?", settings.col-names
            catch
                #console.log "DATA_TABLE: Error getting filtered: ", e, tabledata
                null

        @set \create-view, create-view

        @observe \tabledata, ->
            #console.log "ORDER_TABLE: observing tabledata..."
            create-view!

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


        @on do
            clicked: (args) ->
                context = args.context
                index = context.id
                unless (@get \clickedIndex) is index
                    # trigger only if there is a change
                    console.log "ORDER_TABLE: clicked!!!", args, index

                    @set \clickedIndex, index
                    tabledata = @get \tabledata
                    curr = [.. for tabledata when .._id is index].0
                    @set \curr, curr
                    console.log "Clicked a row: ", (@get \curr)

                    if typeof! settings.on-create-view is \Function
                        settings.on-create-view.call this, curr

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
                @set \curr, (@get \newOrder)!
                @set \addingNew, true
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
                    __.set \saving, "#{__.get \saving} : #{err}"

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


            run-handler: (params) ->
                console.log "Running run-handler event, params: ", params
                (@get \runHandler) params


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

        run-handler: (params) ->
            handlers = __.get \settings.handlers
            param = null

            console.log "orig run-handler: params: ", params
            if params.args
                # this is from ack-button

                if typeof! params.args is \Array
                    console.log "lann???"
                    args = unpack pack params.args
                    handler = args.shift!
                    params.args = args
                    console.log "heyecan yok, sakin..."
                else
                    handler = params.args
                    params.args = null

                param = [params]

            else
                # this is from normal button
                if typeof! params is \Array
                    # from normal button, as array
                    [handler, ...param] = params
                else
                    handler = params

            console.log "Handler: ", handler
            console.log "Param: ", param

            if typeof handlers[handler] is \function
                #console.log "RUNNING HANDLER: #{handler}(#{param})"
                return handlers[handler].apply __, param
            else
                console.log "no handler found with the name: ", handler

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
