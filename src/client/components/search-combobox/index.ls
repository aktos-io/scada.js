require! aea: {sleep}

component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        #console.log "DATA: ", data

        # USING EXTERNAL DATA (IE. Not from database directly)
        #console.log "COMBOBOX: using data: ", data

        function observe-selected
            selected = __.get \selected
            default-data = __.get \defaultData
            try
                throw if (Number selected) isnt (parse-int selected)
                selected = parse-int selected

            data = __.get \data
            if selected in [..id for data when ..id not in [..id for default-data]]
                $ __.find \* .selectpicker 'val', selected
                __.set \selected-name, [..name for data when ..id is selected].0
                console.log "COMBOBOX selected id:::", selected
            else
                console.log "COMBOBOX: selected value is not in dataset, ds: ", selected , [..id for data]

                nonexist = default-data.0.id
                console.log "non existent entry is: ", nonexist
                __.set \selected-name, ''
                __.set \iselected, nonexist
                __.set \selected, nonexist
                #$ __.find \* .selectpicker 'val', '-111'

        do function observe-data
            #console.log "COMBOBOX: observing....", new-val
            default-data = __.get \defaultData
            data =  __.get \data
            data = default-data ++ data
            __.set \selectionList, data
            #$ '.selectpicker' .selectpicker 'refresh'
            #console.log "COMBOBOX: re-rendering!"
            $ __.find \* .selectpicker \render
            $ __.find \* .selectpicker \refresh

        <- sleep 1000ms
        __.observe \data, (new-val)->
            observe-data!

        __.set \iselected, __.get \selected 
        __.observe \selected, (new-val) ->
            observe-selected!

        __.observe \iselected, (val) ->
            if val in [..id for (__.get 'data')]
                console.log "selection is valid: ", val
            else
                console.log "selection is INVALID: ", val
            __.set \selected, val



    onteardown: ->
        console.log "destroying select picker..."
        $ @find \* .selectpicker \destroy

    data: ->
        selected: -1
        iselected: -111

        default-data:
            * id: -111
              name: "Seçim Yapılmadı"
            ...
