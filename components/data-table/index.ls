require! 'prelude-ls': {
    split, take, join, lists-to-obj, sum, filter
    camelize, find, reject, find-index, compact
}
require! 'aea': {sleep, merge, clone, unix-to-readable, pack, VLogger, promisify}
require! 'actors': {RactiveActor}
require! 'sifter': Sifter
require! 'dcs/lib/asciifold': asciifold

Ractive.components['data-table'] = Ractive.extend do
    template: require('./data-table.pug')
    isolated: yes
    onrender: ->>
        @set \readonly, if @partials.editForm then no else yes

        settings = @get \settings
        @actor = new RactiveActor this, do
            name: 'data-table'
            debug: settings.debug
        @logger = new VLogger this, (settings.name or \data-table)

        # check parameters
        try
            unless typeof! settings is \Object
                throw "No settings found!"

            unless settings.name
                throw 'data-table name is required'

            if typeof! settings.save in <[ Function AsyncFunction ]>
                settings.save = promisify settings.save.bind this
 
            if typeof! settings.on-create-view in <[ Function AsyncFunction ]>
                settings.on-create-view = promisify settings.on-create-view.bind this
                
            if settings.data?
                unless typeof! settings.data is \Function
                    throw "data must be a function."
                settings.data = settings.data.bind this

            if typeof! settings.col-names isnt \Function
                colnames = settings.col-names
                settings.col-names = ~>
                    return colnames
            else
                settings.col-names = settings.col-names.bind this

            unless settings.on-init
                throw "on-init is required"
            else
                settings.on-init = promisify settings.on-init.bind this
        catch
            @actor.send 'app.log.err', do
                title: 'data-table component'
                message: e
            return

        opening-dimmer = $ @find \.table-section-of-data-table

        # throw error if save function is used without defining beforehand
        unless settings.save
            settings.save =  promisify (ctx, curr, proceed) ~>
                proceed "No save function is defined!"

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
            #console.log "Sifter now has: ", tableview_filtered
            @set \sifter, new Sifter(tableview_filtered)
            #console.log "Sifter is:", @get \sifter

            if @get \clickedIndex
                index = that
                unless find (.id is index), @get \tableview
                    console.warn "I think that row '#{index}' is deleted, closing."
                    @fire \closeRow
                else if not @get \openedRow
                    # open if we have a clicked index
                    @logger.clog "Open previously clicked index"
                    @fire \openRow, {}, index
            else
                @fire \doSearchText

        open-item-page = (id) ~>
            index = find-index (.id is id), @get('tableview_filtered')
            if index?
                @set \currPage, index / settings.page-size
                @refresh!

        @observe \tableview, (_new) ~>
            @logger.clog "DEBUG MODE: tableview changed, refreshing..." if @get \debug
            @refresh!

        search-rate-limit = null
        search-text-global = null
        @observe \searchText, (text) ~>
            search-text-global := text
            @fire \doSearchText

        sleep 100ms, ~>
            @observe \opened-row, (index) ~>
                if index
                    @fire \openRow, {}, that
                else
                    @fire \closeRow

        $(document).keyup (e) ~> 
            if e.key is "Escape" # escape key maps to keycode `27`
                @fire 'make_row_normal'

        events =
            openRow: (ctx, id) ->>
                if (@get \openingRow) or (@get \openedRow)
                    @logger.cwarn "do not allow multiple clicks"
                    return
                await sleep 0
                index = id or ctx.get \.id
                @logger.clog "Setting index to ", index
                await @set \clickedIndex, index

                if find (.id is index), @get \tableview
                    row = that
                else
                    @logger.clog "No such index can be found: #{index}"
                    return

                if @get \addingNew
                    return @logger.cwarn "adding new, not opening any rows"

                @logger.clog "Clicked to open #{index}"
                await @set \openingRow, yes
                await @set \openedRow, no
                await @set \openingRowMsg, "Opening #{index}..."
                opening-dimmer.dimmer \show
                row-clone = clone row
                await @set \tmp, {}
                await @set \curr, {}

                # scroll to the newly opened row
                await sleep 100ms
                animation-duration = 200ms
                offset = $ "tr[data-anchor='#{index}']" .offset!
                $ 'html, body' .animate do
                    scroll-top: (offset?.top or 0) - (window.top-offset or 0)
                    , animation-duration
                await sleep animation-duration

                try 
                    curr = await settings.on-create-view row-clone
                    await @set \curr, curr
                    await @set \origCurr, clone (@get \curr)
                    await @set \row, row-clone
                    opening-dimmer.dimmer \hide
                    await @set \openingRow, no
                    await @set \openedRow, yes
                    await @set \openingRowMsg, ""
                    await @set \lastIndex, index
                    ctx.resolve?!
                catch err 
                    console.error "error while creating view: ", err
                    @logger.error "Error while opening row: " + pack(err), ~> 
                        @fire \closeRow
                        ctx.reject?!

            make_row_full_screen: (ctx) -> 
                @set "data_table_class_row_full_screen", "__data-table-opened-row-full-screen__"
                x = $ @find '.__data-table-opened-row-full-screen__' .0.clientHeight
                $('body').css('height', "1px")
                @set "print_mode", true
                @set "@global.fullScreen", "data-table"
                @set "data_table_class_row_full_screen", "data-table-opened-row-full-screen"
                ctx.resolve?!

            make_row_normal: (ctx) -> 
                @set "print_mode", false
                @set "@global.fullScreen", null
                @set "@global.fullScreenHeightStyle", "" 
                @set "data_table_class_row_full_screen", ""    
                $('body').css('height', "")
                ctx.resolve?!

            delete: ->
                @set 'curr._deleted', yes

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
                    if (@get \curr) and pack(@get \origCurr) isnt pack(@get \curr)
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
                @set \openingRow, no
                opening-dimmer.dimmer \hide

            end-editing: ->
                @set \clickedIndex, null
                @set \editable, no
                @set \editingDoc, null

            addNew: (ctx) ->>
                if @get \openedRow
                    return @logger.info do
                        closable: yes
                        message: "a row is opened, not adding new."

                @set \prepareAddingNew, yes
                @set \row, {}
                @set \editable, yes
                try 
                    template = await settings.on-create-view null
                    await @set \curr, template
                    await @set \origCurr, clone (@get \curr)
                    @set \prepareAddingNew, no
                    @set \addingNew, yes
                catch err
                    return @logger.error do
                        closable: yes
                        message: err

            save: (ctx) ->>
                btn = ctx.component
                try btn.state \doing
                try 
                    await settings.save ctx, @get('curr')
                    await @set \origCurr, @get('curr')
                    @update \curr
                    try btn.state \done...
                catch
                    try btn.error err

            doSearchText: (ctx) !->
                text = search-text-global
                try clear-timeout search-rate-limit
                @set \searching, yes
                search-rate-limit := sleep 500ms, ~>
                    tableview_filtered = if text
                        search-fields = <[ id ]> ++ (settings.search?fields or settings.search-fields or <[ value.description ]>)
                        result = @get \sifter .search asciifold(text), do
                            #fields: ['id', 'value.description']
                            fields: search-fields
                            sort: [
                                {
                                    field: (settings.search?sort?field or search-fields.1), 
                                    direction: (settings.search?sort?direction or 'asc')
                                }
                            ]
                            nesting: yes
                            conjunction: "and"
                         
                        #console.log "search result is:", result
                        x = []
                        for result.items
                            x.push (@get \tableview_filtered .[..id])
                        if @get \clickedIndex
                            x.push (find (.id is that), @get \tableview)

                        #console.log "result of search '#{text}': ", result.items
                        #console.log "tableview_filtered: ", @get \tableview_filtered
                        x
                    else
                        # restore the last filtered content
                        _filter = @get(\selectedFilter)
                        @get(\dataFilters)[_filter] @get \tableview
                    <~ set-immediate
                    @set \currPage, 0
                    @set \tableview_visible, tableview_filtered
                    #console.log "search for '#{text}' returned #{tableview_filtered.length} results"
                    @set \searching, no

        # register events
        @on (events <<< settings.handlers)

        # register data
        for data, value of settings.data!
            @set data, if typeof! value is \Function
                value.bind this
            else
                value

        # should be after registering data
        @observe \@global.session.token, ~>
            @set \tableview, []
            @set \colNames, settings.col-names!
            @refresh!

        # run init function
        await settings.on-init!
        await @set \firstRunDone, yes

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
        tmp: {}
        new_attachments: {}
        searchText: ''
        sifter: null
        searching: no
        data_table_class_row_full_screen: ""
        print_mode: false

        is-editing-row: (index) ->
            state = no
            if @get \editable
                clicked-index = @get \clickedIndex
                state = index is clicked-index
            #if state => @logger.clog "Now editing #{index}"
            return state

        is-viewing-row: (index) ->
            state = no
            if @get \openedRow
                clicked-index = @get \clickedIndex
                state = index is clicked-index
            #if state => @logger.clog "Now viewing #{index}"
            return state

        isOpeningOrViewingRow: (index) ->
            clicked-index = @get \clickedIndex
            state = index is clicked-index and not @get \editable
            #if state => @logger.clog "Now viewing #{index}"
            return state

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
