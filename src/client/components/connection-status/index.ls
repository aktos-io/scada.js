require! 'aea': {sleep}
component-name = "connection-status"

Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes

    oninit: ->
        __ = @

        db = @get \db

        feed?.cancel!
        feed = db.changes {+live, +retry, since: \now}
            .on \error, (err) ->
                #console.log ":::::::::::: FEED CANCELLED :::::::::::::"
                __.set \dbConnection, err
                feed.cancel!
            .on 'change', (change) ->
                #console.log "change detected!", change
                __.set \dbConnection, change


        db-err, db-info <- db.info

        __.set \connectionOk, yes if db-err is null

        __.observe \dbConnection, (changed) ->
            #console.log "Db connection changed::: ", changed
            db-err, db-info <- db.info
            if not db-err
                console.log "setting connection yes"
                __.set \connectionOk, yes

            if changed?.code is \ETIMEDOUT
                console.log "handled db error"
                __.set \connectionOk, no
                <- :lo(op) ->
                    db-err, db-info <- db.info
                    if not db-err
                        return op!
                    <- sleep 5000ms
                    console.log "Connection Retrying.."
                    lo(op)

                __.set \connectionOk, yes




        __.on do
            connection: (val) ->
                console.log "Clicked is running ", val


    data:
        connection-ok: no
