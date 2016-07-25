require! aea: {sleep}

component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        data = @get \data
        #console.log "DATA: ", data
        # USING EXTERNAL DATA (IE. Not from database directly)
        #console.log "COMBOBOX: using data: ", data
        <- sleep 10ms
        __.set \selectionList, data
        __.observe \data, (new-val)->
            #console.log "COMBOBOX: observing....", new-val
            __.set \selectionList, new-val
            #$ '.selectpicker' .selectpicker 'refresh'
            #console.log "COMBOBOX: re-rendering!"
            $ __.find \* .selectpicker \render
            $ __.find \* .selectpicker \refresh

        __.observe \selected, (new-val) ->
            selected = __.get \selected
            __.set \selected-name, [..name for data when ..id is selected].0
            try
                throw if (Number selected) isnt (parse-int selected)
                selected = Number selected

            if selected in [..id for data]
                $ __.find \* .selectpicker 'val', selected
                console.log "COMBOBOX selected:::", selected
            else
                console.log "COMBOBOX: selected value is not in dataset, ds: ", selected , [..id for data]
                $ __.find \* .selectpicker 'val', null

        <- sleep 0ms
        #console.log "COMBOBOX: first rendering!"
        $ __.find \* .selectpicker \render
        $ __.find \* .selectpicker \refresh


    onteardown: ->
        console.log "destroying select picker..."
        $ @find \* .selectpicker \destroy

    data: ->
        selected: -1
        example-data:
            * name: 'example1'
              id: 1
            * name: 'example2'
              id: 2
