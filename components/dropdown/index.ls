require! 'prelude-ls': {find, empty}
require! 'dcs/browser': {RactiveActor}
require! 'aea': {sleep}


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

    onrender: ->
        __ = @
        dd = $ @find '.ui.dropdown'
        dd.add-class \multiple if @get \multiple
        dd.add-class \inline if @get \inline
        dd.add-class \fluid if @get \fit-width
        keyField = @get \keyField
        nameField = @get \nameField

        debug = @get \debug

        set-item = (key-value) ~>
            if @get \data
                item = find ((x) -> x[keyField] is key-value), that
                @set \item, item
                @set \selected-name, item?[nameField]
                @set \selected-key, item?[keyField]

        @observe \data, (data) ~>
            if debug => @actor.log.log "data is changed: ", data
            if data => unless empty data
                @set \loading, no
            dd
                .dropdown 'restore defaults'
                .dropdown 'destroy'
                .dropdown 'setting', do
                    forceSelection: no
                    on-change: (value, text, selected) ~>
                        value = try
                            selected.attr 'data-value'
                        catch
                            null

                        debugger if debug
                        if value
                            @set \selected, value
                            set-item value

        @observe \selected, (_new) ->
            if debug => @actor.log.log "selected is changed: ", _new
            if _new not in [undefined, null]
                dd.dropdown 'set selected', _new
                set-item _new

    data: ->
        keyField: \id
        nameField: \name
        nothingSelected: '---'
        selected: null
        item: {}
        loading: yes
