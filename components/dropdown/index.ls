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
        update-dropdown = (_new) ~>
            debugger if @get \debug
            @actor.log.log "#{@_guid}: selected is changed: ", _new if @get \debug
            # TODO: add selected items to the `dataReduced`
            if @get \multiple
                dd.dropdown 'set exactly', _new
            else
                dd.dropdown 'set selected', _new

        const c = @getContext @target .getParent yes
        c.refire = yes

        set-item = (value-of-key) ~>
            if @get \data
                data = that
                if @get \multiple
                    items = []
                    selected-keys = []
                    selected-names = []
                    if value-of-key
                        _values = that.split ','

                        for val in _values
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
                                @fire \select, c, selected
                            else
                                @set \selected-key, selected[keyField]

                        unless @get \async
                            @set \item, selected
                            @set \selected-name, selected[nameField]


        shandler = null

        @observe \data, (data) ~>
            @actor.log.log "data is changed: ", data if @get \debug

            do  # show loading icon
                @set \loading, yes
                <~ sleep 500ms
                if data and not empty data
                    @set \loading, no
                    @set \dataReduced, small-part-of data

            @set \sifter, new Sifter(data)

            dd
                .dropdown 'restore defaults'
                .dropdown 'destroy'
                .dropdown 'setting', do
                    forceSelection: no
                    full-text-search: (text) ~>
                        if text
                            result = @get \sifter .search asciifold(text), do
                                fields: ['id', 'name', 'description']
                                sort: [{field: 'name', direction: 'asc'}]
                                nesting: no
                                conjunction: "and"
                            @set \dataReduced, [data[..id] for small-part-of result.items]
                        else
                            @set \dataReduced, small-part-of data

                    on-change: (_value, _text, selected) ~>
                        if shandler then that.silence!
                        @actor.log.log "#{@_guid}: dropdown is changed: ", _value if @get \debug
                        debugger if @get \debug
                        set-item _value
                        if shandler then that.resume!
                        @set \dataReduced, small-part-of data

            if (typeof! data is \Array) and not empty data
                <~ sleep 10ms
                if @get \selected-key
                    update-dropdown that
                    set-item that

        unless @get \multiple
            shandler = @observe \selected-key, (_new) ~>
                if @get \debug
                    @actor.c-log "selected key set to:", _new
                if _new
                    unless find (.[keyField] is _new), @get \dataReduced
                        @push \dataReduced, find (.[keyField] is _new), @get \data
                    sleep 10ms ~>
                        update-dropdown _new
                    set-item _new
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
