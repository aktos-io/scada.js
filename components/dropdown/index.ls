Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->         
        if @get \key
            @set \keyField, that

        if @get \name
            @set \nameField, that

    onrender: ->
        __ = @
        ui = $ @find '.ui.dropdown'
        ui.add-class \multiple if @get \multiple
        ui.add-class \inline if @get \inline
        ui.add-class \fluid if @get \fit-width

        ui.dropdown do
            forceSelection: no
            on-change: (value, text, selected) ->
                __.set \selected, value

        @observe \selected, (_new) ->
            if _new not in [undefined, null]
                ui.dropdown 'set selected', _new

    data: ->
        keyField: \id
        nameField: \name
