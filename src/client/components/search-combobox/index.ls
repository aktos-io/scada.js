require! aea: {sleep}

component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        try
            db = @get \db
            console.log "COMBOBOX: Database object is: ", db
            view = @get \view
        catch
            view = null

        function update-combobox
            console.log "SEARCH_COMBOBOX: Updating combobox..."
            err, res <- db.query view, {+include_docs}
            if err
                console.log "ERROR: order table: ", err
            else
                console.log "SEARCH_COMBOBOX updated: ", res
                __.set \selectionList, [{name: ..doc.product-name, id: ..doc._id} for res.rows]

        data = @get \data
        if data
            console.log "COMBOBOX: using data: ", data
            @set \selectionList, data
        else if view
            console.log "Combobox using view...", view
            update-combobox!

            db.changes {since: 'now', +live, +include_docs}
                .on \change, (change) ->
                    console.log "search-combobox detected change!", change
                    update-combobox!
        else
            @set \selectionList, (@get \exampleData)

        console.log "COMBOBOX: refreshing...."
        __.observe \data, (new-val)->
            __.set \selectionList, new-val
            #$ '.selectpicker' .selectpicker 'refresh'
            console.log "COMBOBOX: refreshed!"
            $ __.find \* .selectpicker \render

        <- sleep 0ms
        console.log "AAAAAAAAAAAAAAAAAAAAAAAAAA"
        $ __.find \* .selectpicker \render

    data: ->
        selected: -1
        example-data:
            * name: 'example1'
              id: 1
            * name: 'example2'
              id: 2
