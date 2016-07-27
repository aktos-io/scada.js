
require! 'prelude-ls': {split, take, join, lists-to-obj, sum}
require! 'randomstring': random
require! 'aea': {sleep}

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

        try
            col-list = split ',', settings.col-names
            @set \columnList, col-list
        catch
            console.log "DATA_TABLE: problem with col-names: ", e
            return

        if settings.debug
            console.log "HEY HEY"

        @set \dataFilters, settings.filters

        do function create-view param
            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            #console.log "DATA_TABLE: Running create-view...", selected-filter if settings.debug
            try
                #return if typeof! tabledata isnt \Array
                ffunc = filters[selected-filter]
                filtered = ffunc.apply __, [tabledata, param] if typeof ffunc is \function
                if typeof settings.after-filter is \function
                    #console.log "DATA_TABLE: applying after-filter: ", settings.after-filter if settings.debug
                    settings.after-filter.apply __, [filtered, (view) -> __.set \tableview, view]
                else
                    console.log "after-filter is not defined?", settings.col-names
            catch
                console.log "DATA_TABLE: Error getting filtered: ", e, tabledata
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
            console.log "DATA TABLE: INFO: ", e

        @observe \changes, ->
            if typeof on-change is \function
                #if settings.debug then console.log "DATA_TABLE: ON-CHANGE IS FUNCTION..."
                on-change!
            else
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
                console.log "ORDER_TABLE: clicked!!!", args, index

                @set \clickedIndex, index
                tabledata = @get \tabledata
                @set \curr, [.. for tabledata when .._id is index].0
                console.log "Clicked a row: ", (@get \curr)


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
                console.log "AAAAAAAAAAAAAAAAAAAAAAAAAAAa"
                console.log "ORDER_TABLE: filter is set to #{filter-name}"
                @set \selectedFilter, filter-name if filter-name
                create-view!

    data: ->
        __ = @
        instance: __
        new-order: ->
            console.log "Returning new default value: ", __.get \default
            unpack pack __.get \default
        curr: null
        id: \will-be-random
        tabledata: null
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

        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index

        refresh: ->
            console.log "TABLE IS REFRESHING!!!"
            __.fire \setFilter, \all
            x = (__.get \create-view)
            console.log "TABLE REFRESH HAS FUNC: ", x
            x!
