Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        ui = $ @find '.ui.dropdown'
        ui.add-class \multiple if @get \multiple
        ui.add-class \inline if @get \inline
        ui.add-class \fluid if @get \fit-width

        ui.dropdown do
            force-selection: no
            on-change: (value, text, selected) ->
                __.set \selected, value

        @observe \selected, (_new) ->
            if _new not in [undefined, null]
                ui.dropdown 'set selected', _new

    data: ->
        fitWidth: no
