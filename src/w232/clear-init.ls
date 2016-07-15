require! '../lib/aea': {
    sleep, wait-for, timeout-wait-for, go, is-waiting
    merge, unpack, pack, repl, config, debug-log
}
require! http

function align-left width, inp
    x = (inp + " " * width).slice 0, width

get-logger = (src) ->
    (...x) -> debug-log.call this, (align-left 15, "#{src}") + ":" + x.join('')

i = 0
gen-req-id = (digit) ->
    i++

# Long polling class

!function LongPolling settings
    # Default timeout is 128 seconds for TCP/IP
    @settings = settings
    @content =
        node: @settings.id
    @events =
        error: []
        connect: []
        disconnect: []
        data: []
    @connected = no
    @connecting = no
    @reconnect-interval = 1000ms

LongPolling::on = (event, callback) ->
    @events[event] ++= callback

LongPolling::trigger = (name, ...event) ->
    [..apply @, event for @events[name] when typeof .. is \function]

LongPolling::send = (msg, callback) ->
    log = get-logger \SEND
    try
        throw 'you MUST connect first!' if not @connected
        @post-raw {data: msg}, callback
        #callback err, res
        log "WARNING: not calling callback!"
    catch
        log "error: ", e
        callback e, null

LongPolling::get-raw = (...query, callback) ->
    query = query.0
    # query must be an object, eg:
    #
    #     {hello: 'world', test: 123, ...}
    #
    __ = @
    log = get-logger \GET_RAW
    try
        throw 'not connected' if not @connected
        # get some data
        query-str = "?" + ["#{key}=#{value}" for key, value of query].join "&"
        log query-str
        <- sleep 0 # context switch
        options =
            host: __.settings.host
            port: __.settings.port
            method: \GET
            path: __.settings.soci-path + query-str

        request-id = gen-req-id 3
        log "new request: ", request-id


        req = http.get options, (res) ->
            res.on \data, (data) ->
                log "got data: ", data
                callback null, data

            res.on \error, ->
                log "#{request-id} Response Error: ", err

            res.on \close, ->
                log "#{request-id} request is closed by server... "

        req.on \error, (err) ->
            log "req \##{request-id} has error: ", err
            <- sleep 1000ms # REMOVE THIS
            __.connect!

    catch
        log "get-raw returned with error: ", e
        callback e, null
        __.connect!



LongPolling::post-raw = (msg, callback) ->
    __ = @
    log = get-logger "POST_RAW"

    err = no
    content = @content `merge` msg  # merge with node id

    content-str = pack content

    options =
        host: @settings.host
        port: @settings.port
        method: \POST
        path: @settings.sico-path
        headers:
            "Content-Type": "application/json"
            "Content-Length": content-str.length

    request-id = gen-req-id 3
    log "New POST request: ", request-id

    req = http.request options, (res) ->
        res.on \data, (data) ->
            log "#{request-id} got data: ", data
            try
                callback null, unpack data
            catch
                log "CAN NOT UNPACK DATA: ", data
                log "err: ", e

        res.on \error, ->
            log "#{request-id} Response Error: ", err

        res.on \close, ->
            log "#{request-id} request is closed by server... "

    req.on \error, (err) ->
        # called when we closed server with Ctrl+C
        log "#{request-id} Request Error: ", err
        __.connected = no
        __.trigger \error, err
        # call the callback with error
        callback err, null
        log "trying to reconnect in #{__.reconnect-interval}ms..."
        <- sleep __.reconnect-interval
        __.connect!

    req.write content-str
    req.end!



LongPolling::connect = (next-step) ->
    __ = @
    log = get-logger \CONNECT

    if @connecting
        log "Already started..."
        return
    @connecting = yes
    @connected = no

    log "Trying to connect to server..."
    err, data <- __.post-raw {ack: "200"}
    if not err
        try
            throw "not my server!" if data.ack isnt \OK
            log "Connection seems ok, starting all tasks..."
            <- sleep 0
            __.connected = yes
            __.receive-loop!
            next-step! if typeof next-step is \function
        catch
            log "Error: ", e
            log "Retrying in #{__.reconnect-interval}ms..."
            <- sleep __.reconnect-interval
            __.connect!
    __.connecting = no



LongPolling::receive-loop = ->
    __ = @
    log = get-logger \RECEIVE_LOOP

    log "starting..."
    <- :lo(op) ->
        receiver-id = gen-req-id 3
        err, res <- __.get-raw
        if err
            log "#{receiver-id} has Error: ", err
            __.trigger \error, err
            log "Breaking receive loop..."
            return op!
        else
            log "#{receiver-id} got data...", res
            __.trigger \data, res
            lo(op)


# End of LongPolling class

do function init
    log = get-logger \MAIN

    comm = new LongPolling do
        host: 'localhost'
        port: 5656
        sico-path: '/send'
        soci-path: '/receive'
        id: 'abc123'

    comm
        ..on \error, (err) ->
            log "COMM-ERR:: ", err

        ..on \connect, (info) ->
            log "Connected to server. Server info: ", info

        ..on \disconnect, ->
            log "Disconnected from server!!!"

        ..on \data, (data) ->
            log "Received DATA: ", data

    err, res <- comm.get-raw {hello: \world}
    log "get raw returned with err, res: ", err, res

    err <- comm.send {mydata: \hello}
    log "send hello: ", err  # should return err: "you MUST connect first!"

    <- comm.connect!

    log "it seems connection is ok, continuing..."
    return

    do
        <- :lo(op) ->
            return
            err <- comm.send do
                temperature: Math.random!
            if err
                log "We couldn't send to data because: ", err
            <- timeout-wait-for 10000ms, \temperature-measured
            lo(op)
