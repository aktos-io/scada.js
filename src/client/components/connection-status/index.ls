require! 'aea': {sleep}
component-name = "connection-status"

Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes

    oninit: ->
        __ = @

        db = @get \db

        do
            <- :lo(op) ->
                err, db-info <- db.info
                __.set \connectionOk, not err
                #__.set \dbInfo, db-info if db-info
                <- sleep 5000ms
                #console.log "Heartbeat (5ms): Database connection.. "
                lo(op)


        __.on do
            connection: (val) ->
                console.log "Clicked is running ", val


    data:
        connection-ok: no
