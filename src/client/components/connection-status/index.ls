require! 'aea': {sleep, is-db-alive}
Ractive.components['connection-status'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    oninit: ->
        __ = @

        db = @get \db
        do
            <- :lo(op) ->
                err <- is-db-alive db
                __.set \connectionOk, not err
                #__.set \dbInfo, db-info if db-info
                <- sleep 5000ms
                #console.log "Heartbeat (5ms): Database connection.. "
                lo(op)


        __.on do
            connection: (val) ->
                console.log "Clicked is running ", val


    data: -> 
        connection-ok: no
