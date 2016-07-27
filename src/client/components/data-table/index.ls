
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

        @set \dataFilters, settings.filters

        do function create-view param
            filters = __.get \dataFilters
            selected-filter = __.get \selectedFilter
            tabledata = __.get \tabledata
            #console.log "DATA_TABLE: Running create-view...", tabledata
            try
                throw "tabledata is empty" if typeof! tabledata isnt \Array
                filter = filters[selected-filter]
                filtered = filter.apply __, [tabledata, param] if typeof filter is \function
                if typeof settings.after-filter is \function
                    #console.log "ORDER_TABLE: applying after-filter: ", settings.after-filter
                    settings.after-filter.apply __, [filtered, (view) -> __.set \tableview, view]
                else
                    console.log "after-filter is not defined?", settings.col-names
            catch
                console.log "DATA_TABLE: Error getting filtered: ", e, tabledata
                null

        @observe \tabledata, ->
            #console.log "ORDER_TABLE: observing tabledata..."
            create-view!

        try
            throw "DATA TABLE: on-change is not a function!" if typeof! settings.on-change isnt \Function
            do on-change = ->
                settings.on-change.apply __

            @observe \changes, ->
                on-change!
        catch
            console.log "Err: ", e



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

            setfilter: (filter-name) ->
                console.log "ORDER_TABLE: filter is set to #{filter-name}"
                @set \filterOpts.selected, filter-name

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
