
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
        col-list = split ',', settings.cols
        @set \columnList, col-list

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


        filters = settings.filters
        console.log "ORDER_TABLE: DEBUG: got filters: ", filters
        if filters
            console.log "Setting data filters..."
            @set \dataFilters, filters



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
            all: (docs, param) ->
                console.log "ORDER_TABLE: using default filter!",param, docs
                [id: ..id, cols: [..id, ..key, ..value] for docs]

        filter-opts:
            params: \mahmut
            selected: \all

        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

        is-clicked: (index) ->
            clicked-index = @get \clickedIndex
            index is clicked-index

        get-filtered: (tabledata, param, this_) ->
            __ = this_.instance
            filters = __.get \dataFilters
            filter-opts = __.get \filterOpts
            try
                filter = filters[filter-opts.selected]
                filter(tabledata, param, this_) if typeof filter is \function
            catch
                console.log "Error getting filtered: ", e
                null
