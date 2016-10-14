component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        select = $ @find "select"

        # Selectize documentation
        #
        #   https://github.com/selectize/selectize.js/tree/master/docs
        #

        select.selectize do
            maxItems: 1
            valueField: \id
            labelField: \name
            searchField: \name

        select.on \change, (x) ->
            id = x.target.value
            value = x.target.text-content
            __.set \selected, id
            __.set \selectedText, value
            console.log "selected: ", id, "value: ", value

        box = select.0.selectize

        @observe \data, (new-data, old-data) ->
            if new-data
                box
                    ..add-option new-data
                    ..refresh-items!


        # set initial value
        selected = @get \selected
        if selected
            box.set-value selected

    data: ->
        selected: null
        selected-text: ''
