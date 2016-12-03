component-name = "checkbox"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: yes
    oninit: ->
        __ = @
        @on do
            toggleChecked: ->
                __.set \checked, (not __.get \checked)
    data: ->
        checked: no
