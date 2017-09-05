require! 'prelude-ls': {find}
require! 'dcs/browser': {RactiveActor}
require! 'aea': {sleep}


Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @actor = new RactiveActor this, \dropdown

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

        @observe \data, (data) ~>
            if debug => @actor.log.log "data is changed: ", data
            dd
                .dropdown 'restore defaults'
                .dropdown 'destroy'
                .dropdown 'setting', do
                    forceSelection: no
                    on-change: (value, text, selected) ~>
                        value = try
                            (find (-> it[nameField] is text), data)[keyField]
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
        selected: \hello
        item: {}
