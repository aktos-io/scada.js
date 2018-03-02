"""
Design considerations (TO BE COMPLETED)

* Multiple:

    1. If data is not available but `selected-key` is set, dropdown should display
    a loading icon
"""
require! 'prelude-ls': {find, empty, take}
require! 'actors': {RactiveActor}
require! 'aea': {sleep}

require! 'sifter': Sifter
require! '../data-table/sifter-workaround': {asciifold}

small-part-of = (data) ->
    if data? and not empty data
        take 100, data
    else
        []

Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @actor = new RactiveActor this, do
            name: "dropdown.#{@_guid}"
            debug: yes

        if @get \key
            @set \keyField, that

        if @get \name
            @set \nameField, that

        if @get \disabled-mode
            @set \class, "#{@get 'class'} disabled"

        #@link \selected-key, \selected

    onrender: ->
        dd = $ @find '.ui.dropdown'
        if @get \multiple
            dd.add-class \multiple

        dd.add-class \inline if @get \inline
        dd.add-class \fluid if @get \fit-width
        keyField = @get \keyField
        nameField = @get \nameField

        external-change = no
        update-dropdown = (_new) ~>
            debugger if @get \debug
            @actor.log.log "#{@_guid}: selected is changed: ", _new if @get \debug
            external-change := yes
            if @get \multiple
                dd.dropdown 'set exactly', _new
            else
                dd.dropdown 'set selected', _new
            external-change := no

        const c = @getContext @target .getParent yes
        c.refire = yes

        set-item = (value-of-key) ~>
            if @get \data
                data = that
                if @get \multiple
                    items = []
                    selected-keys = []
                    selected-names = []
                    for val in value-of-key when val
                        if find (.[keyField] is val), data
                            items.push that
                            selected-keys.push that[keyField]
                            selected-names.push that[nameField]
                            if @get \debug
                                @actor.c-log "Found #{val} in .[#{keyField}]", that[keyField]
                        else
                            # how can't we find the item?
                            debugger
                    debugger if @get \debug
                    @set \item, unless empty items => items else [{}]
                    @set \selected-name, selected-names
                    @set \selected-key, selected-keys
                    @fire \select, {}, (unless empty items => items else [{}])
                else
                    # set a single value
                    if find (.[keyField] is value-of-key), data
                        selected = that
                        if @get('selected-key') isnt that[keyField]
                            @actor.c-log "selected key is really changed to:", selected[keyField]
                            if @get \debug
                                @actor.c-log "Found #{value-of-key} in .[#{keyField}]", selected, selected[keyField]
                            if @get \async
                                @fire \select, c, selected, (err) ~>
                                    unless err
                                        @set \item, selected
                                    else
                                        @actor.c-err "Error reported for dropdown callback: ", err
                            else
                                @set \selected-key, selected[keyField]

                        unless @get \async
                            @set \item, selected
                            @set \selected-name, selected[nameField]
        shandler = null
        @observe \data, (data) ~>
            @actor.log.log "data is changed: ", data if @get \debug

            do  # show loading icon while data is being fetched
                @set \loading, yes
                <~ sleep 300ms
                if data and not empty data
                    @set \loading, no
                    @set \dataReduced, small-part-of data
                    @set \sifter, new Sifter(data)

                    # Update dropdown visually when data is updated
                    if selected = @get \selected-key
                        if @get \multiple
                            <~ sleep 10ms
                            update-dropdown selected
                        else
                            update-dropdown selected
                            set-item selected
        dd
            .dropdown 'restore defaults'
            .dropdown 'setting', do
                forceSelection: no
                full-text-search: (text) ~>
                    data = @get \data
                    if text
                        result = @get \sifter .search asciifold(text), do
                            fields: ['id', 'name', 'description']
                            sort: [{field: 'name', direction: 'asc'}]
                            nesting: no
                            conjunction: "and"
                        @set \dataReduced, [data[..id] for small-part-of result.items]
                    else
                        @set \dataReduced, small-part-of data

                on-change: (value, text, selected) ~>
                    return if external-change
                    shandler?.silence!
                    @actor.log.log "#{@_guid}: dropdown is changed: ", value if @get \debug
                    if @get \multiple
                        @actor.c-log "#{@_guid}: multiple: value: ", value
                        set-item unless value? => [] else value.split ','
                    else
                        set-item value
                    shandler?.resume!
                    @set \dataReduced, small-part-of @get \data

        if @get \multiple
            shandler = @observe \selected-key, (_new, old) ~>
                debugger
                if typeof! _new is \Array
                    if JSON.stringify(_new or []) isnt JSON.stringify(old or [])
                        if not empty _new
                            <~ sleep 10ms
                            update-dropdown _new
                        else
                            # clear the dropdown
                            dd.dropdown 'restore defaults'
        else
            shandler = @observe \selected-key, (_new) ~>
                if @get \debug
                    @actor.c-log "selected key set to:", _new
                if _new
                    item = find (.[keyField] is _new), @get \dataReduced
                    unless item
                        item = find (.[keyField] is _new), @get \data
                        @push \dataReduced, item
                    @set \item, item
                    sleep 10ms ~>
                        # Workaround for dropdown update bug
                        update-dropdown _new
                else
                    # clear the dropdown
                    @set \item, {}
                    dd.dropdown 'restore defaults'

        @on do
            teardown: ->
                dd.dropdown 'destroy'

    data: ->
        data: undefined
        dataReduced: []
        keyField: \id
        nameField: \name
        nothingSelected: '---'
        item: {}
        loading: yes
        sifter: null

        # this is very important. if you omit this, "selected"
        # variable will be bound to class prototype (thus shared
        # across the instances)
        'selected-key': null
        'selected-name': null
