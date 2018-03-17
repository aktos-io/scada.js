require! 'prelude-ls': {
    split, take, join, lists-to-obj, sum, filter
    camelize, find, reject, find-index
}
require! 'aea': {sleep, merge, clone, unix-to-readable, pack, VLogger}
require! 'actors': {RactiveActor}

require! 'sifter': Sifter
require! './sifter-workaround': {asciifold}

Ractive.components['data-table'] = Ractive.extend do
    template: RACTIVE_PREPARSE('data-table.pug')
    isolated: yes
    onrender: ->
        readonly = if @partials.editForm then no else yes
        title-provided = if @partials.addnewTitle then yes else no
        @set \readonly, readonly

        settings = @get \settings
        @logger = new VLogger this, (settings.name or \my)

        @actor = new RactiveActor this, do
            name: 'data-table'
            debug: settings.debug


        # check parameters
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
                settings.after-filter = settings.after-filter.bind this

            if typeof! settings.on-save is \Function
                settings.on-save = settings.on-save.bind this

            if typeof! settings.data is \Function
                settings.data = settings.data.bind this

            unless settings.on-init
                throw "on-init is required"
            else
                settings.on-init = settings.on-init.bind this
        catch
            @actor.send 'app.log.err', do
                title: 'data-table component'
                message: e
            return

        # function to use adding on new document
        unless typeof! settings.on-new-document is \Function
            settings.on-new-document = (template, next) ->
                @set \curr, template
                next!
        settings.on-new-document = settings.on-new-document.bind this

        @get-default-document = ~>
            try
                if typeof settings.default is \function
                    return settings.default.call this
                else
                    clone settings.default
            catch
                @logger.cerr e



        @set \colNames, settings.col-names
        opening-dimmer = $ @find \.table-section-of-data-table

        # assign filters
        data-filters = {}
        for name, func of settings.filters
            data-filters[name] = func.bind this
        data-filters['all'] = (x) ~> x
        @set \dataFilters, data-filters

        @refresh = ~>
            filter-func = @get(\dataFilters)[@get(\selectedFilter)]
            if typeof! filter-func isnt \Function
                @logger.cerr 'Filter function is not a function'

            # get tableview
            tableview = @get \tableview

            # filter documents
            tableview_filtered = filter-func tableview
            @set \tableview_filtered, tableview_filtered

        open-item-page = (id) ~>
            index = find-index (.id is id), @get('tableview_filtered')
            if index?
                @set \currPage, index / settings.page-size
                @refresh!


        @observe \tableview, (_new) ~>
            @logger.clog "DEBUG MODE: tableview changed, refreshing..." if @get \debug
            @set \sifter, new Sifter(_new)
            @refresh!


        search-rate-limit = null
        @observe \searchText, (text) ~>
            try clear-timeout search-rate-limit
            search-rate-limit := sleep 200ms, ~>
                tableview_filtered = if text
                    result = @get \sifter .search asciifold(that), do
                        fields: ['id', 'value.description']
                        sort: [{field: 'name', direction: 'asc'}]
                        nesting: yes
                        conjunction: "and"

                    x = []
                    for result.items
                        x.push (@get \tableview .[..id])
                    if @get \clickedIndex
                        x.push (find (.id is that), @get \tableview)
                    x
                else
                    @get \tableview
                @set \currPage, 0

                @set \tableview_filtered, tableview_filtered
                console.log "search for '#{text}' returned #{tableview_filtered.length} results"



        @observe \tableview_filtered, (filtered) ~>
            settings.after-filter filtered, (items) ~>
                if items.length > 0
                    if items.0.cols.length isnt settings.col-names.length
                        @logger.error "Column count does not match with after-filter output!"
                        return
                    for i in items when i.id in [undefined, null]
                        return @logger.cerr "id can not be null or undefined: #{pack i}."
                @set \tableview_visible, items

        events =
            clicked: (ctx, row) ->
                index = row.id
                return if @get(\clickedIndex) is index # do not allow multiple clicks
                if @get \addingNew
                    return @logger.cwarn "adding new, not opening any rows"

                @set \clickedIndex, index
                @set \openingRow, yes
                @set \openedRow, no
                @set \openingRowMsg, "Opening #{index}..."
                opening-dimmer.dimmer \show
                row-clone = clone row
                @set \_tmp, {}
                curr <~ settings.on-create-view.call this, row-clone
                @set \curr, that if curr
                sleep 100ms, ~>
                    @set \origCurr, clone (@get \curr)
                @set \row, row-clone
                opening-dimmer.dimmer \hide
                @set \openingRow, no
                @set \openedRow, yes
                @set \openingRowMsg, ""
                @set \lastIndex, index
                # scroll to the row
                # TODO

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            set-filter: (event, filter-name) ->
                @logger.clog "DATA_TABLE: filter is set to #{filter-name}"
                @set \selectedFilter, filter-name if filter-name
                @set \currPage, 0
                @refresh!

            select-page: (event, page-num) ->
                @set \currPage, page-num
                #@refresh!

            go-to-opened: (ctx) ->
                item-id = @get \lastIndex
                open-item-page item-id

            close-row: ->
                <~ :lo(op) ~>
                    if pack(@get \origCurr) isnt pack(@get \curr)
                        @logger.cwarn "Not closing row because there are unsaved changes."
                        @logger.clog "orig: ", @get \origCurr
                        @logger.clog "curr: ", @get \curr
                        answer <~ @logger.yesno do
                            title: "Discard changes?"
                            message: "If you select 'Drop Changes' all changes will be lost."
                            buttons:
                                drop:
                                    color: \red
                                    text: 'Drop Changes'
                                    icon: \trash

                                cancel:
                                    color: \green
                                    text: 'Cancel'
                                    icon: \undo

                        if answer is \drop
                            return op!
                        else
                            @logger.cwarn "Cancelled discarding changes."
                    else
                        return op!

                @set \addingNew, false
                @fire \endEditing
                @set \openedRow, no
                opening-dimmer.dimmer \hide

            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null

            add-new-document: (ev, data) ->
                if (@get \openedRow) and (@get('mode') isnt 'add-new')
                    return @logger.info do
                        closable: yes
                        message: "a row is opened, not adding new."

                ev.component?.fire \state, \doing
                template = if data
                    data
                else
                    @get-default-document!
                @set \prepareAddingNew, yes
                @set \row, {}
                @set \editable, yes
                @set \origCurr, clone template
                <~ settings.on-create-view.call this, null
                <~ settings.on-new-document template
                @set \prepareAddingNew, no
                @set \addingNew, yes
                ev.component?.fire \state, \normal


            save: (ev, val) ->
                ev.component.fire \state, \doing
                ...args <~ @fire 'onSave', ev, @get(\curr)
                if args.length isnt 1
                    ev.component.error """
                        Coding error: Save function requires error argument upon
                        calling the callback."""
                    return
                err = args.0
                if err
                    ev.component.error pack err
                else
                    @set \origCurr, (@get \curr)
                    ev.component.fire \state \done...
                    @refresh!

            on-save: (ev, curr, next) ->
                timeout = 15_000ms
                ev.component.heartbeat timeout

                unless curr._id
                    return next "ID is required!"

                unless curr._rev
                    # this is a new document, use exact ID or pfx + autoincrement
                    # if curr._id has numeric portion, this is an exact ID
                    # else this is a prefix
                    if settings.autoincrement is on
                        @actor.c-log "Autoincrement is set to 'yes', autoincrementing."
                        curr._id = curr._id.to-upper-case!
                        if curr._id.split /[0-9]+/ .length is 1
                            # no numeric part, this is a prefix
                            curr._id += '####'

                if @get \new_attachments
                    curr._attachments = (curr._attachments or {}) <<< that

                err, res <~ @get \db .put curr, {timeout}
                if err
                    @logger.clog "err is: ", err
                else
                    #@logger.clog "res is: ", res
                    @set \curr._id, res.id     # if `_id` is assigned automatically
                    @set \curr._rev, res.rev   # rev will be updated on save
                next err


        # register events
        @on events <<< settings.handlers

        for data, value of settings.data
            @set data, value

        # run init function
        <~ settings.on-init
        @set \firstRunDone, yes

        switch @get \mode
        | 'add-new' => @fire \addNewDocument

    data: ->
        firstRunDone: no
        curr: null
        handlers: {}
        readonly: no
        tableview: []
        tableview_visible: []
        editable: false
        clicked-index: null
        last-index: null
        cols: null
        col-names: null
        addingNew: no
        view-func: null
        selected-filter: \all
        curr-page: 0
        opening-row: no
        opening-row-msg: ''
        _tmp: {}
        new_attachments: {}
        searchText: ''
        sifter: null
        is-editing-row: (index) ->
            return no unless @get \editable
            clicked-index = @get \clickedIndex
            index is clicked-index

        is-viewing-row: (index) ->
            return no if not @get \openedRow
            clicked-index = @get \clickedIndex
            index is clicked-index

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

        run-handler: (...params) ~>
            handlers = @get \settings.handlers
            handler = params.shift!

            if typeof handlers[handler] is \function
                #@logger.clog "RUNNING HANDLER: #{handler}(#{param})"
                return handlers[handler].apply this, params
            else
                @logger.clog "no handler found with the name: ", handler


        # utility functions
        # ---------------------------------------------------------------
        range: (_from, _to) ->
            try
                range = [i for i from parse-int(_from) to parse-int(_to)]
                range
            catch
                @logger.clog "error in range generator: from: #{_from}, to: #{_to}"

        unix-to-readable: unix-to-readable

        lookup: (obj-array, key-field, key-value) ->
            x = find (.[key-field] is key-value), obj-array
            @logger.clog "lookup input: ", obj-array, key-field, key-value
            @logger.clog "lookup result: ", x
            x
