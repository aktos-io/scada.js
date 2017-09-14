require! 'prelude-ls': {find, empty}
require! 'dcs/browser': {RactiveActor}
require! 'aea': {sleep}

class RactiveVar
    (@ractive, @name) ->

    observe: ->
        @observe-handle = @ractive.observe @name, ...arguments

    set: ->
        @ractive.set @name, ...arguments

    set-silent: ->
        @observe-handle.silence! if @observe-handle
        @ractive.set @name, ...arguments
        @observe-handle.resume! if @observe-handle

Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @actor = new RactiveActor this, do
            name: \dropdown
            debug: yes

        if @get \key
            @set \keyField, that

        if @get \name
            @set \nameField, that

        if @get \disabled-mode
            @set \class, "#{@get 'class'} disabled"

        @link \selected, \selected-key

    onrender: ->
        dd = $ @find '.ui.dropdown'
        if @get \multiple
            dd.add-class \multiple
            debugger if @get \debug
            @set \selected-key, []
            @set \item, [{}]


        dd.add-class \inline if @get \inline
        dd.add-class \fluid if @get \fit-width
        keyField = @get \keyField
        nameField = @get \nameField


        set-item = (value-of-key) ~>
            if @get \data
                data = that
                if @get \multiple
                    _values = value-of-key.split ','
                    items = []
                    selected-keys = []
                    selected-names = []
                    for val in _values
                        if find (-> it[keyField] is val), data
                            items.push that
                            selected-keys.push that[keyField]
                            selected-names.push that[nameField]
                        else
                            # how can't we find the item?
                            debugger

                    @set \item, unless empty items => items else [{}]
                    @set \selected-key, selected-keys
                    @set \selected-name, selected-names

                else
                    # set a single value
                    if find (-> it[keyField] is value-of-key), data
                        @set \item, that
                        @set \selected-key, that[keyField]
                        @set \selected-name, that[nameField]
                    else
                        # why didn't we find it?
                        debugger


        @observe \data, (data) ~>
            @actor.log.log "data is changed: ", data if @get \debug

            if data and not empty data
                @set \loading, no
            dd
                .dropdown 'restore defaults'
                .dropdown 'destroy'
                .dropdown 'setting', do
                    forceSelection: no
                    full-text-search: 'exact'
                    on-change: (_value, _text, selected) ~>
                        debugger if @get \debug
                        set-item _value

        @observe \selected-key, (_new) ->
            debugger if @get \debug
            @actor.log.log "selected is changed: ", _new if @get \debug
            if _new in [undefined, null] and not @get \multiple
                return
            dd.dropdown 'set selected', _new
            #set-item _new,

    data: ->
        data: undefined
        keyField: \id
        nameField: \name
        nothingSelected: '---'
        selected: null
        item: {}
        loading: yes
