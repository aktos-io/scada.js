require! 'aea-embedded': {LongPolling}
require! 'aea': {pack, sleep}

get-serial = ->
    (parse-int Math.random! * 10000).to-string!

log = console.log

comm = new LongPolling do
    host: '192.168.2.103'
    port: 5656  # aktos-server
    #port: 5655  # cloudant.com (via proxy (iisexpress))
    path:
        db: '/todo'
        changes: '/todo/_changes'
        info: '/'
    id: get-serial!

comm
    ..on \error, (err) ->
        log "COMM-ERR:: ", err

    ..on \connect, (info) ->
        log "Connected to server. Server info: ", pack info

    ..on \disconnect, ->
        log "Disconnected from server!!!"

    ..on \data, (data) ->
        log "Received DATA: ", pack data

err <- comm.connect!
log "it seems connection is ok, continuing..."


log "sending hello..."
<- comm.send {mydata: \hello}
log "send hello: ", err
# should print an error now: "you MUST connect first!"

err, data <- comm.get '/todo/mahmut1'
log "err: ", err if err
log "data: ", pack data


if false
    i = 0
    <- :lo(op) ->
        err <- comm.send do
            _id: "embedded-#{i++}"
            temperature: Math.random!
        if err
            log "We couldn't send to data because: ", err
        <- sleep 10000ms, \temperature-measured
        lo(op)
