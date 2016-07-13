
component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        __ = @
        db = @get \db
        console.log "Database object is: ", db

        view = @get \view

        if view
            do function update-combobox
                err, res <- db.query view, {+include_docs}
                if err
                    console.log "ERROR: order table: ", err
                else
                    console.log "Updating table: ", res
                    __.set \selectionList, [{name: ..doc.product-name, id: ..doc._id} for res.rows]
                    $ '.selectpicker' .selectpicker 'refresh'

        else
            data = @get \data
            @set \selectionList, data

    data: ->
        selected: -1 
        data:
            * name: 'example1'
              id: 1
            * name: 'example2'
              id: 2
