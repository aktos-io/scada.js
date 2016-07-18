require! '../lib/aea': {
    sleep, wait-for, timeout-wait-for, go, is-waiting
    merge, unpack, pack, repl, config, get-logger
}
require! '../lib/aea-embedded': {LongPolling}

do function init
    log = get-logger \MAIN

    comm = new LongPolling do
        host: 'localhost'
        port: 5656  # aktos-server
        #port: 5655  # cloudant.com (via proxy (iisexpress))
        path:
            db: '/todo'
            changes: '/todo/_changes'
            info: "/"
        id: 'abc123'

    comm
        ..on \error, (err) ->
            log "COMM-ERR:: ", err

        ..on \connect, (info) ->
            log "Connected to server. Server info: ", pack info

        ..on \disconnect, ->
            log "Disconnected from server!!!"

        ..on \data, (data) ->
            log "Received DATA: ", pack data

    err <- comm.send {mydata: \hello}
    log "send hello: ", err
    # should print an error now: "you MUST connect first!"

    <- comm.connect!
    log "it seems connection is ok, continuing..."

    err, data <- comm.get '/todo/mahmut-1'
    log "err: ", err if err
    log "data: ", pack data
    do
        i = 0
        <- :lo(op) ->
            err <- comm.send do
                _id: "embedded-#{i++}"
                temperature: Math.random!
            if err
                log "We couldn't send to data because: ", err
            <- timeout-wait-for 10000ms, \temperature-measured
            lo(op)
