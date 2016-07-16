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

    @retry-count = 0
    @retry-interval = 500ms
    @max-interval = 5000ms

LongPolling::on = (event, callback) ->
    @events[event] ++= callback

LongPolling::trigger = (name, ...event) ->
    [..apply @, event for @events[name] when typeof .. is \function]

LongPolling::send = (msg, callback) ->
    log = get-logger \SEND
    try
        throw 'you MUST connect first!' if not @connected
        @post-raw msg, callback
    catch
        log "error: ", e
        @comm-err e, callback

LongPolling::get = (...params, callback) ->
    path = params.0
    query = params.1

    log = get-logger \SEND
    log "path: ". path, "query: ", query
    try
        throw 'You MUST connect first!' if not @connected
        @get-raw query, path, callback
    catch
        log "error: ", e
        @comm-err e, callback


LongPolling::get-raw = (...params, callback) ->
    [query, path] = params
    # query must be an object, eg:
    #
    #     {hello: 'world', test: 123, ...}
    #
    __ = @
    log = get-logger \GET_RAW

    path = @settings.path.changes if not path

    log "path: ", path
    log "query: ", pack query
    try
        # TODO: ENABLE THIS LINE throw 'not connected' if not @connected
        # get some data
        query-str = "?" + ["#{key}=#{value}" for key, value of query].join "&"
        log "query string: ", query-str if query?
        <- sleep 0 # context switch
        options =
            host: __.settings.host
            port: __.settings.port
            method: \GET
            path: path + query-str
            #headers: {}
        request-id = gen-req-id 3

        chunks = ""
        req = http.get options, (res) ->
            res.on \data, (data) ->
                log "got raw data: ", data
                chunks += data

            res.on \error, ->
                log "res error: ", err
                throw

            res.on \end, ->
                log "End of transmission!"
                try
                    callback null, unpack chunks
                catch
                    # data might be something like "Cannot GET /nonexistent_path"
                    callback {exception: e, message: chunks}, null

            res.on \close, ->
                log "#{request-id} request is closed by server... "
                throw

        req.on \error, (err) ->
            log "req error: ", err
            __.comm-err err, callback
    catch err
        log "get-raw returned with error: ", err
        __.comm-err err, callback


LongPolling::comm-err = (reason, callback) ->
    log = get-logger \COMM_ERR
    log "comm error happened: ", reason
    log "connected: ", @connected
    log "connecting: ", @connecting
    callback reason, null
    if @connected
        @trigger \error, reason
        @trigger \disconnect
        @connected = no

    if @connecting
        log "Already trying to reconnect!..."
    else
        log "Triggering connect!"
        @connect!

LongPolling::post-raw = (...params, callback) ->
    [msg, path] = params
    __ = @
    log = get-logger "POST_RAW"


    try
        throw 'documents must have and _id field' if msg._id is null
        throw 'not connected' if not @connected

        path = "#{@settings.path.db}/#{msg._id}"
        err = no
        content = @content `merge` msg  # merge with node id

        content-str = pack content

        options =
            host: @settings.host
            port: @settings.port
            method: \PUT
            path: path
            headers:
                "Content-Type": "application/json"
                "Content-Length": content-str.length

        request-id = gen-req-id 3
        log "initiating new request: ", request-id

        req = http.request options, (res) ->
            res.on \data, (data) ->
                log "got data: ", data
                try
                    callback null, unpack data
                catch
                    log "CAN NOT UNPACK DATA: ", data
                    log "err: ", e
                    callback e, null

            res.on \error, ->
                log "#{request-id} Response Error: ", err
                throw "RES.ON ERROR???"

            res.on \close, ->
                log "#{request-id} request is closed by server... "
                throw "RES.ON CLOSE???"

        req.on \error, (err) ->
            # called when we closed server with Ctrl+C
            log "#{request-id} Request Error: ", err
            __.comm-err err, callback

        req.write content-str
        req.end!

    catch err
        log "raw-get has exception: ", err
        __.comm-err err, callback


LongPolling::connect = (next-step) ->
    __ = @
    log = get-logger \CONNECT

    @connecting = yes

    interval = @retry-count * @retry-interval
    interval = @max-interval if interval > @max-interval
    @retry-count++

    log "retrying in #{interval}ms..." if interval > 0
    <- sleep interval

    log "Trying to connect to server..."
    err, data <- __.get-raw {hello: "world"}, __.settings.path.info
    try
        throw "connection error" if err
        if data.aktos is \Welcome
            log "connected to aktos device server"
        else if data.couchdb is \Welcome
            log "connected to CouchDB"
        else
            throw "unknown server!"
        log "Connection seems ok, starting all tasks..."
        <- sleep 0
        __.retry-count = 0
        __.connected = yes
        __.connecting = no
        __.receive-loop!
        __.trigger \connect, data
        next-step! if typeof next-step is \function
    catch
        log "Error: ", e
        <- sleep 10
        __.connecting = no
        __.connect!



LongPolling::receive-loop = ->
    __ = @
    log = get-logger \RECEIVE_LOOP

    log "started..."
    <- :lo(op) ->
        receiver-id = gen-req-id 3
        err, res <- __.get-raw {since: \now, feed: \longpoll}, @changes
        if err
            log "stopping receive loop: ", err
            # error handlers and reconnection stuff
            # is triggered in @get-raw and @post-raw already
            # so nothing to do here...
            return op!
        else
            log "got data: ", pack res
            __.trigger \data, res
            lo(op)


# End of LongPolling class

do function init
    log = get-logger \MAIN

    comm = new LongPolling do
        host: 'localhost'
        #port: 5656  # aktos-server
        port: 5655  # cloudant.com (via proxy (iisexpress))
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
