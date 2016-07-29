require! 'aea': {sleep, pack}
require! 'config': {Config}
require! 'connect-to-wifi': {WifiConnect}
require! 'long-polling': {LongPolling}


log = console.log

wifi = new WifiConnect aktos =
    essid: \aea
    passwd: \084DA789BF

comm = new LongPolling do
    host: '192.168.2.103'
    port: 5656  # aktos-server
    #port: 5655  # cloudant.com (via proxy (iisexpress))
    path:
        db: '/todo'
        changes: '/todo/_changes'
        info: "/"
    id: get-serial!

on-init = ->
    console.log "Started on-init!"
    err <- wifi.connect
    if err
        console.log "err wifi connect: ", err
        return
    console.log "Connected to wifi, continuing..."

    comm
        ..on \error, (err) ->
            log "COMM-ERR:: ", err

        ..on \connect, (info) ->
            log "Connected to server. Server info: ", pack info

        ..on \disconnect, ->
            log "Disconnected from server!!!"

        ..on \data, (data) ->
            log "Received DATA: ", pack data

    log "After2 LONG_POLLING: ", process.memory!
    err <- comm.connect!
    log "it seems connection is ok, continuing..."


    log "sending hello..."
    <- comm.send {mydata: \hello}
    log "send hello: ", err
    # should print an error now: "you MUST connect first!"

    err, data <- comm.get '/todo/mahmut-1'
    log "err: ", err if err
    log "data: ", pack data
    do
        i = 0
        <- :lo(op) ->
            err <- comm.send do
                _id: "embedded-#{i++}"
                temperature: Math.random! * 100 
            if err
                log "We couldn't send to data because: ", err
            <- sleep 10000ms
            lo(op)
