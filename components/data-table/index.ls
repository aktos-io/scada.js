require! 'prelude-ls': {
    split, take, join, lists-to-obj, sum, filter
    camelize, find, reject, find-index
}
require! 'aea': {sleep, merge, pack, unpack, unix-to-readable}
require! 'dcs/browser': {CouchProxy}
require! './vlogger': {VLogger}

Ractive.components['data-table'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        readonly = if @partials.editForm then no else yes
        title-provided = if @partials.addnewTitle then yes else no
        @set \readonly, readonly

    onrender: ->
        @logger = new VLogger this
        settings = @get \settings
        try
            unless typeof! settings is \Object
                throw "No settings found!"
            unless settings.name
                throw 'data-table name is required'
            unless typeof! settings.col-names is \Array
                throw 'Column names are missing'
            unless settings.default
                throw 'Default document is required'
            unless settings.after-filter
                throw "after-filter is required"
            else
                settings.after-filter.bind this
        catch
            @logger.error e
            return

        get-default-document = ~>
            try
                if typeof settings.default is \function
                    return settings.default.call this
                else
                    unpack pack settings.default
            catch
                @logger.error e

        @set \columnList, settings.col-names
        db = new CouchProxy get-default-document!.type
        opening-dimmer = $ @find \.table-section-of-data-table

        # assign handlers
        handlers = {}
        for handler, func of settings.handlers
            handlers[handler] = func.bind this

        @set \handlers, handlers

        # assign filters
        data-filters = {}
        for name, func of settings.filters
            data-filters[name] = func.bind this
        data-filters['all'] = (x) ~> x
        @set \dataFilters, data-filters

        debugger
        create-tableview = ~>
            filter-func = @get(\dataFilters)[@get(\selectedFilter)]
            if typeof! filter-func isnt \Function
                @logger.error 'Filter function is not a function'

            # get tableview
            tableview = @get \tableview

            # filter documents
            tableview_filtered = filter-func tableview

            # calculate which items to show in tableview
            items = do ~>
                if settings.page-size > 0
                    curr-page = @get \currPage
                    min = (x, y) -> if x < y then x else y
                    return do
                        from: curr-page * settings.page-size
                        to: min (((curr-page + 1) * settings.page-size) - 1), (tableview_filtered.length - 1)
                else
                    return do
                        from: 0
                        to: tableview_filtered.length - 1

            # calculate visible items
            visible-items = for index, entry of tableview_filtered
                if items.from <= index <= items.to
                    entry

            settings.after-filter visible-items, (items) ~>
                @set \tableview_visible, items


        events =
            clicked: (event, context) ->
                __ = @
                index = context.id
                clicked-index = @get \clickedIndex
                if clicked-index isnt null
                    return
                if clicked-index is index
                    # do not allow more than one click
                    return

                tabledata = @get \tabledata
                if typeof! tabledata is \Object
                    for key, value of tabledata
                        if index is value._id
                            curr = unpack pack tabledata[key]
                else
                    curr = try
                        unpack pack find (._id is index), tabledata
                    catch
                        unpack pack context

                if curr
                    @set \curr, curr
                else
                    curr = index

                @set \currView, context
                @set \openingRow, yes
                @set \openedRow, no
                @set \clickedIndex, index
                @set \lastIndex, index

                dom = $ "tr[data-anchor='#{index}']"

                opening-dimmer.dimmer \show

                # scroll to index as soon as it is clicked
                scroll-to index

                if typeof! settings.on-create-view is \Function
                    settings.on-create-view.call __, curr, ->
                        __.set \openingRow, no
                        __.set \openedRow, yes
                        __.set \openingRowMsg, ""
                        scroll-to index
                        opening-dimmer.dimmer \hide
                else
                    __.set \openingRow, no
                    __.set \openedRow, yes
                    __.set \openingRowMsg, ""
                    scroll-to index
                    opening-dimmer.dimmer \hide

            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null
                # DO NOT ADD THIS AGAIN: (@get \create-view) (@get \curr)

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            set-filter: (event, filter-name) ->
                console.log "DATA_TABLE: filter is set to #{filter-name}"
                @set \selectedFilter, filter-name if filter-name
                @set \currPage, 0
                create-view!


            select-page: (event, page-num) ->
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
                new-order = get-default-document!
                new-order._id = db.gen-entry-id!

                @set \curr, new-order
                @set \addingNew, true

                if typeof! settings.on-create-view is \Function
                    settings.on-create-view.call this, new-order, ->


            new-order-close: ->
                #console.log "ORDER_TABLE: Closing edit form..."
                @set \addingNew, false
                @fire \endEditing
                opening-dimmer.dimmer \hide

            save: (event, e) ->
                __ = @
                order-doc = @get \curr

                button-state = (state, msg) ->
                    e.component.fire \state, state, msg if e

                button-state \doing

                console.log "Saving new order document: ", order-doc
                if not order-doc._id?
                    console.log "Generating new id for the document!"
                    order-doc = order-doc `merge` {_id: gen-entry-id!}

                err, res <- db.save order-doc
                if err
                    console.log "Error putting new order: ", err
                    button-state \error, err.message
                else
                    (__.get \create-view) order-doc
                    order-doc._rev = res.rev
                    __.set \curr, order-doc

                    button-state \done...
                    # TODO: use "kick-changes! function"
                    __.add \changes

            add-new-entry: (event, keypath) ->
                __ = @
                editing-doc = __.get \curr
                try
                    template = (get-default-document!)[keypath].0
                catch
                    err-message = "Problem with keypath: #{keypath}: #{e}"
                    console.error err-message
                    __.fire \showError, err-message
                    return

                if typeof! editing-doc[keypath] isnt \Array
                    console.log "Keypath is not an array, converting to array"
                    editing-doc[keypath] = []
                editing-doc[keypath] ++= template

                console.log "adding new entry: ", template
                __.set \curr, editing-doc


            delete-document: (event, e) ->
                e.component.fire \state, \doing
                curr = @get \curr
                curr.type = "_deleted_#{curr.type}"
                err, res <- db.save curr
                return e.component.fire \state, \error, err.message  if err
                e.component.fire \state, \done

                tabledata = reject (._id is curr._id), __.get \tabledata
                __.set \tabledata, tabledata
                (__.get \create-view)!

            show-error: (event, msg, callback) ->
                @logger.error msg, callback

            show-info: (event, msg, callback) ->
                @logger.info msg, callback


        events `merge` handlers
        # modify "save" handler
        _save = events.save
        events.save = (...args) ->
            e = args.1
            _save.apply __, args
            e.component.set \onDone, ->
                if __.get \addingNew
                    __.set \addingNew, false

        # register events
        @on events

    data: ->
        __ = @
        curr: null
        handlers: {}
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
        selected-filter: \all
        curr-page: 0
        opening-row: no
        opening-row-msg: ''
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-viewing-row: (index) ->
            clicked-index = @get \clickedIndex
            opened = @get \openedRow
            index is clicked-index and opened

        is-opening-now: (row-index) ->
            opening = @get \openingRow
            opened = @get \openedRow
            clicked-index = @get \clickedIndex

            if clicked-index is row-index and opening and not opened
                yes
            else
                no

        is-last-clicked: (index) ->
            x = index is @get \lastIndex

        is-disabled: (index) ->
            clicked-index = @get \clickedIndex
            if clicked-index isnt null and clicked-index isnt index
                yes
            else
                no

        run-handler: (params) ~>
            handlers = @get \settings.handlers
            param = null

            #console.log "orig run-handler: params: ", params
            if params.args
                # this is from ack-button

                if typeof! params.args is \Array
                    args = unpack pack params.args
                    handler = args.shift!
                    params.args = args
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

            #console.log "Handler: ", handler
            #console.log "Param: ", param

            if typeof handlers[handler] is \function
                #console.log "RUNNING HANDLER: #{handler}(#{param})"
                return handlers[handler].apply this, param
            else
                console.log "no handler found with the name: ", handler




        # utility functions
        # ---------------------------------------------------------------
        range: (_from, _to) ->
            try
                range = [i for i from parse-int(_from) to parse-int(_to)]
                range
            catch
                console.log "error in range generator: ", _from, _to

        unix-to-readable: unix-to-readable
