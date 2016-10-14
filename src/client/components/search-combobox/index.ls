component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        select = $ @find "select"

        select.selectize!

        select.on \change, (x) ->
            id = x.target.value
            value = x.target.text-content
            __.set \selected, id
            __.set \selectedText, value

        selected = @get \selected
        if selected
            select.0.selectize.set-value selected
