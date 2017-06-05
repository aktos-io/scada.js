require! 'aea': {sleep, merge}
export db =
    gen-entry-id: -> Date.now!
    save: (something, next) ->
        console.log "DB SAVE CALLED: ", something
        <- sleep 2000ms
        next err=null, something `merge` {_rev: Date.now!}

    get: (something, next) ->
        console.log "DB GET CALLED: ", something
        <- sleep 2000ms
        next err=null, something `merge` {_rev: Date.now!}

    query: (something, next) ->
        console.log "DB QUERY CALLED: ", something
        <- sleep 2000ms
        next err=null, something `merge` {_rev: Date.now!}
