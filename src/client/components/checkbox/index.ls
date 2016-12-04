Ractive.components.checkbox = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        __ = @
        @on do
            toggleChecked: ->
                __.set \checked, (not __.get \checked)
    data: ->
        checked: no
