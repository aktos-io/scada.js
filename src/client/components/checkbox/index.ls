component-name = "checkbox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        @on do
            toggleChecked: ->
                __.set \checked, (not __.get \checked)
    data: ->
        checked: no
