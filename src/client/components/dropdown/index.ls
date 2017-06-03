Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @set 'fitWidth', @get 'fit-width'
    onrender: ->
        __ = @
        ui = $ @find '.ui.dropdown'
        ui.attr \multiple, '' if @get \multiple
        ui.add-class \inline if @get \inline
        ui.dropdown do
            force-selection: no
            on-change: (value, text, selected) ->
                __.set \selected, value

        @observe \selected, (_new) ->
            if _new not in [undefined, null]
                ui.dropdown 'set selected', _new

    data: ->
        fitWidth: no
