require! 'prelude-ls': {
    split, take, join, lists-to-obj, sum, filter
    camelize, find, reject, find-index
}
require! 'aea': {sleep, merge, pack, unpack, unix-to-readable}
require! 'randomstring': random

Ractive.components['data-table'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        readonly = if @partials.editForm then no else yes
        title-provided = if @partials.addnewTitle then yes else no
        @set \readonly, readonly
        @set \_titleProvided, title-provided
        @set \hasAddNewButton, (not readonly and title-provided)

    onrender: ->
        __ = @

        db = @get \db
        console.error "No database object is passed to data-table!" unless db

        modal-error = $ @find \.modal-error

        modal-error.modal do
            keyboard: yes
            focus: yes
            show: no

        modal-new = $ @find \.modal-new
        modal-new.modal do
            keyboard: no
            focus: yes
            show: no
            backdrop: \static

        settings = @get \settings

        prev-url = null
        open-row = (no-need-updating) ->
            #console.warn "open row disabled..."
            new-url = __.get \curr-url
            if new-url and new-url isnt prev-url
                tableview = __.get \tableview
                if tableview
                    for part in new-url.split '/'
                        rel-entry = find (.id is part), tableview
                        index = find-index (.id is part), tableview
                        if rel-entry
                            console.warn "I know this guy: ", part
                            if settings.page-size and settings.page-size > 0
                                curr-page = Math.floor (index / settings.page-size)
                                __.set \currPage, curr-page
                            __.set \clickedIndex, null

                            __.fire \clicked, {context: rel-entry}
                            __.update! unless no-need-updating
                            prev-url := new-url
                            return

        @observe \curr-url, ->
            open-row!

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

        @set \dataFilters, settings.filters

        first-run-started = no
        create-view = (curr) ->
            unless __.get \firstRunDone
                console.warn "data-table: create-view is called before first run!"
                return

            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            try
                throw if tabledata.length is 0
            catch
                return

            if curr
                curr-in-table = find (._id is curr._id), tabledata
                unless curr-in-table
                    # tabledata does not contain curr, add it to the beginning
                    tabledata.unshift curr
                else
                    # update curr in tabledata
                    # replace all properties with new one
                    for i of curr-in-table
                        delete curr-in-table[i]
                    for i of curr
                        curr-in-table[i] = curr[i]

                __.set \tabledata, tabledata


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

                        __.set \tableview_visible, [view[index] for index of view when items.from <= index <= items.to ]
                    else
                        __.set \tableview_visible, view

                    # for debugging purposes
                    __.add \createViewCounter
                catch
                    console.error e
                    debugger

            unless filtered
                console.warn "Filtered data is undefined! "
            else
                settings.after-filter.apply __, [filtered, generate-visible]
                #console.warn "After filter runs so many times???"
                open-row yes


        refresh-view = ->
            if typeof on-change is \function
                #if settings.debug then console.log "DATA_TABLE: ON-CHANGE IS FUNCTION..."
                settings.on-change.apply __
            else
                create-view!


        @set \create-view, create-view


        @observe \enabled, (_new, _old) ->
            if _new and not __.get(\firstRunDone) and not first-run-started
                # Run post init (from instance)
                first-run-started := yes
                # debug: console.log "Initializing tabledata with columns: #{settings.col-names}"
                try
                    if typeof settings.on-init is \function
                        settings.on-init.call this, ->
                            __.set \firstRunDone, yes
                            # debug: console.log "finished initialization #{settings.col-names}"
                            refresh-view!
                        # debug: console.log "started initialization: #{settings.col-names}"


                catch
                    console.error "ERROR FROM DATA_TABLE: on-init: ", e
            else if _old is off and _new is on and __.get(\firstRunDone)
                # debug: console.log "rising edge of enable, trigger change: #{settings.col-names}"
                changes = __.get \changes
                __.set \changes, ++changes
                refresh-view!
            else if not _old and _new
                1
                #console.warn "Ignoring toggle of enabled in data-table for #{settings.col-names}"

        @observe \changes, ->
            if (__.get \enabled) and (__.get \firstRunDone)
                console.log "Refreshing because of changes changed: #{settings.col-names}"
                refresh-view!

        @observe \tabledata, ->
            if (__.get \enabled) and (__.get \firstRunDone)
                console.log "Refreshing because tabledata changed...: #{settings.col-names}"
                refresh-view!


        get-default-document = ->
            try
                def = __.get \settings.default
                if typeof def is \function
                    return def.call __
                else
                    unpack pack def
            catch
                console.error e


        events =
            clicked: (args) ->
                __ = @
                context = args.context
                index = context.id
                unless (@get \clickedIndex) is index
                    # trigger only if there is a change
                    #console.log "ORDER_TABLE: clicked!!!", args, index
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
                    @set \clickedIndex, index
                    @set \lastIndex, index


                    scroll-to = (anchor) ->
                        dom = $ "tr[data-anchor='#{index}']"
                        offset = dom.offset!
                        if offset
                            <- sleep 10m
                            $ 'html, body' .animate do
                                scroll-top: offset.top
                                , 500ms
                        else
                            console.warn "Couldn't find offset of #{index}?"
                            debugger


                    # scroll to index as soon as it is clicked
                    scroll-to index

                    if typeof! settings.on-create-view is \Function
                        settings.on-create-view.call __, curr, ->
                            __.set \openingRow, no
                            __.set \openingRowMsg, ""
                            scroll-to index
                    else
                        __.set \openingRow, no
                        __.set \openingRowMsg, ""
                        scroll-to index





            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null
                # DO NOT ADD THIS AGAIN: (@get \create-view) (@get \curr)

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
                new-order = get-default-document!
                new-order._id = db.gen-entry-id!

                @set \curr, new-order
                @set \addingNew, true
                modal-new.modal \show

                if typeof! settings.on-create-view is \Function
                    settings.on-create-view.call this, new-order, ->


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

                err, res <- db.save order-doc
                if err
                    console.log "Error putting new order: ", err
                    __.set \saving, "#{__.get \saving} : #{err.message}"
                    button-state \error, err.message
                else
                    (__.get \create-view) order-doc
                    order-doc._rev = res.rev
                    __.set \curr, order-doc

                    button-state \done...
                    # TODO: use "kick-changes! function"
                    __.add \changes

            add-new-entry: (keypath) ->
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


            delete-order: (index-str) ->
                [key, index] = split ':' index-str
                index = parse-int index
                editing-doc = @get \curr
                editing-doc[key].splice index, 1
                @set \curr, editing-doc

            delete-document: (e) ->
                __ = @
                e.component.fire \state, \doing
                curr = @get \curr
                curr.type = "_deleted_#{curr.type}"
                err, res <- db.save curr
                return e.component.fire \state, \error, err.message  if err
                e.component.fire \state, \done

                tabledata = reject (._id is curr._id), __.get \tabledata
                __.set \tabledata, tabledata
                (__.get \create-view)!

            show-error: (err-message) ->
                type = modal-error.TYPE_DANGER
                @set \errorMessage, err-message
                modal-error.modal \show

            kick-changes: (ev) ->
                console.log "kicking changes..."
                ev.component.fire \state, \doing
                @add \changes
                @observe-once \createViewCounter, ->
                    ev.component.fire \state, \done...



        events `merge` handlers
        # modify "save" handler
        _save = events.save
        events.save = (...args) ->
            e = args.0
            _save.apply __, args
            e.component.set \onDone, ->
                if __.get \addingNew
                    #e.component.
                    modal-new.modal \hide
                    __.set \addingNew, false

        @on events


    data: ->
        __ = @
        has-add-new-button: no
        deleteDocuments: no
        instance: @
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
        data-filters:
            all: (docs) -> docs
        selected-filter: \all
        curr-page: 0
        dont-watch-changes: no
        error-message: null
        enabled: no
        create-view-counter: 0
        changes: 0
        first-run-done: no
        opening-row: no
        opening-row-msg: ''
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index

        is-last-clicked: (index) ->
            x = index is @get \lastIndex

        run-handler: (params) ->
            handlers = __.get \settings.handlers
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
                return handlers[handler].apply __, param
            else
                console.log "no handler found with the name: ", handler

        trigger-change: ->
            __.set \dontWatchChanges, yes
            __.set \changes, (1 + __.get \changes)

        refresh: (curr) ->
            console.log "TABLE IS REFRESHING!!!"
            __.fire \setFilter, \all
            create-view = __.get \create-view
            create-view curr

        # utility functions
        # ---------------------------------------------------------------
        range: (_from, _to) ->
            try
                range = [i for i from parse-int(_from) to parse-int(_to)]
                range
            catch
                console.log "error in range generator: ", _from, _to

        two-digit: (n) ->
            (Math.round (n * 100)) / 100

        five-digit: (n) ->
            (Math.round (n * 100000)) / 100000

        unix-to-readable: unix-to-readable
