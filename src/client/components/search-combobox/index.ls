require! 'aea': {unpack, pack}
Ractive.components['search-combobox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        select = $ @find "select"
        multiple = @get \multiple

        # Selectize documentation
        #
        #   https://github.com/selectize/selectize.js/tree/master/docs
        #

        select.selectize do
            maxItems: multiple
            valueField: \id
            labelField: \name
            searchField: \name

        @set \__selectize__, select

        select.on \change, (x) ->
            id = x.target.value
            value = x.target.text-content
            if multiple is 1
                __.set \selected, id
                debugger
            else
                multi = []
                for option in x.target
                    multi.push(option.value)
                __.set \selected, multi
                debugger

            #__.set \selectedText, value
            #console.log "selected: ", id, "value: ", value

        box = select.0.selectize
        #default-selected = __.get \selected
        try
            throw if default-selected
            data = __.get \data
            throw if data.length > 1
            default-selected = data.0.id

        @observe \data, (new-data, old-data) ->
            default-selected = __.get \selected
            if new-data
                box
                    ..add-option new-data
                    ..refresh-options false
                    ..set-value default-selected if default-selected
        @observe \selected, (new-val) ->
            if new-val
                box.set-value new-val


    onteardown: ->
        selectize = @get \__selectize__ .0.selectize
        selectize.destroy!

    data: ->
        selected: null
        selected-text: ''
        multiple: 1
        multi-selected: null
        placeholder: "Seçim yapın..."
        __selectize__: null
