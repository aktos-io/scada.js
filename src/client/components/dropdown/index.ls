Ractive.components['dropdown'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        ui = $ @find '.ui.dropdown'
        ui.find 'select' .attr \multiple, ''
        ui.dropdown do
            force-selection: no
            on-change: (value, text, selected) ->
                __.set \selected, value

        @observe \selected, (_new) ->
            unless _new is undefined
                ui.dropdown 'set selected', _new
