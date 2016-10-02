require! aea: {sleep}

component-name = "search-combobox33"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        #console.log "DATA: ", data

        # USING EXTERNAL DATA (IE. Not from database directly)
        #console.log "COMBOBOX: using data: ", data
        select = $ @find \select
        nonexist = @get \defaultData

        # observe `data`, sync with `selection-list`
        do function observe-data
            #console.log "COMBOBOX: observing....", new-val
            data =  __.get \data
            __.set \selectionList, data
            select.selectpicker \render
            select.selectpicker \refresh

        __.observe \data, ->
            observe-data!


        return
        function observe-selected
            selected = __.get \selected
            data = __.get \data
            try
                throw if (Number selected) isnt (parse-int selected)
                selected = parse-int selected
                data = [{id: parse-int(..id), name: ..name} for data]

            return if not data or data.length is 0

            if selected in [..id for data]
                $ __.find \* .selectpicker 'val', selected
                __.set \selected-name, [..name for data when ..id is selected].0
            else
                #console.log "COMBOBOX: selected value is not in dataset, ds: ", selected , [..id for data]


                __.set \selected-name, nonexist.name
                __.set \iselected, nonexist.id
                __.set \selected, nonexist.id


        curr = __.get \selected
        if curr
            __.set \iselected, curr
        else
            __.set \iselected, undefined

        __.observe \selected, (val) ->
            observe-selected!

        __.observe \iselected, (val) ->
            __.set \selected, val



    onteardown: ->
        console.log "destroying select picker..."
        $ @find \select .selectpicker \destroy

    data: ->
        selected: undefined
        default-data:
            * id: void
              name: "Seçim YAPILMADI (555)"
            ...
