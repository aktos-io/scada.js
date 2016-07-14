require! aea: {sleep}

component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        try
            db = @get \db
            #console.log "COMBOBOX: Database object is: ", db
            view = @get \view
        catch
            view = null

        function update-combobox
            #console.log "SEARCH_COMBOBOX: Updating combobox..."
            err, res <- db.query view, {+include_docs}
            if err
                console.log "ERROR: order table: ", err
            else
                #console.log "SEARCH_COMBOBOX updated: ", res
                __.set \selectionList, [{name: ..doc.product-name, id: ..doc._id} for res.rows]
                $ __.find \* .selectpicker \render
                $ __.find \* .selectpicker \refresh

        data = @get \data
        #console.log "DATA: ", data
        #console.log "VIEW:", view
        unless view
            #console.log "COMBOBOX: using data: ", data
            __.set \selectionList, data
            __.observe \data, (new-val)->
                #console.log "COMBOBOX: observing....", new-val
                __.set \selectionList, new-val
                #$ '.selectpicker' .selectpicker 'refresh'
                #console.log "COMBOBOX: re-rendering!"
                $ __.find \* .selectpicker \render
                $ __.find \* .selectpicker \refresh

        else
            #console.log "Combobox using view...", view
            update-combobox!

            /*
            db.changes {since: 'now', +live, +include_docs}
                .on \change, (change) ->
                    console.log "search-combobox detected change!", change
                    update-combobox!
            */

        <- sleep 0ms
        #console.log "COMBOBOX: first rendering!"
        $ __.find \* .selectpicker \render
        $ __.find \* .selectpicker \refresh
        try __.set \selected, (__.get \data).0.id

    data: ->
        selected: -1
        example-data:
            * name: 'example1'
              id: 1
            * name: 'example2'
              id: 2
