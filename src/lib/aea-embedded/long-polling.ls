require! 'aea': {
    sleep, merge, unpack, pack, get-logger
}
log = console.log

require! http

# Long polling class
export !function LongPolling settings
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
    @events[event] = callback

LongPolling::trigger = (name, ...event) ->
    @events[name].apply this, event 

LongPolling::send = (p1, p2, p3) ->
    /*

    ::send msg[, path], callback


    uses `path` if available, else it will try to use @settings.path.db/msg.id
    */

    msg = p1
    callback = p2
    path = "#{@settings.path.db}/#{msg._id}"
    if p3
        callback = p3
        path = p2
    #log "SEND: path", path, "msg", msg

    # log = get-logger \SEND
    try
        throw 'you MUST connect first!' if not @connected
        @put-raw msg, path, callback
    catch
        # log "error: ", e
        @comm-err e, callback

LongPolling::get = (p1, p2, p3) ->
    /*

    ::get path[, query], callback

    */

    path = p1
    callback = p2
    query = {}
    if p3
        callback = p3
        query = p2


    # log = get-logger \SEND
    log "path: ", path, "query: ", query
    try
        throw 'You MUST connect first!' if not @connected
        @get-raw path, query, callback
    catch
        # log "error: ", e
        @comm-err e, callback


LongPolling::get-raw = (path, query, callback) ->
    # query must be an object, eg:
    #
    #     {hello: 'world', test: 123, ...}
    #
    __ = @
    # log = get-logger \GET_RAW
    # log "path: ", path
    # log "query: ", pack query
    try
        # TODO: ENABLE THIS LINE throw 'not connected' if not @connected
        # get some data
        query-str = "?" + ["#{key}=#{value}" for key, value of query].join "&"
        full-path = path + query-str
        #console.log "Full Path: ", full-path
        # log "query string: ", query-str if query?
        <- sleep 0 # context switch
        options =
            host: __.settings.host
            port: __.settings.port
            method: \GET
            path: full-path
            #headers: {}

        chunks = ""
        req = http.get options, (res) ->
            res.on \data, (data) ->
                # log "got raw data: ", data
                chunks += data

            res.on \error, ->
                log "res error: ", err

            end-of-transmission = ->
                # log "End of transmission!"
                try
                    callback null, unpack chunks
                catch
                    try
                        # data might be something like "Cannot GET /nonexistent_path"
                        throw "not found" if (chunks.slice 0, 10) is "CANNOT GET"
                        throw 'unknown message format'
                    catch
                        callback {exception: e, message: chunks}, null

            res.on \end, ->
                end-of-transmission!

            res.on \close, ->
                # This handler is only fired in Espruino, not in Node.js
                #log "request is closed by server... (means end of transmission?) "
                end-of-transmission!

        req.on \error, (err) ->
            __.comm-err err, callback

    catch err
        # log "get-raw returned with error: ", err
        __.comm-err err, callback


LongPolling::comm-err = (reason, callback) ->
    # log = get-logger \COMM_ERR
    log "comm error happened: ", reason
    #log "connected: ", @connected
    #log "connecting: ", @connecting
    callback reason, null
    if @connected
        @trigger \error, reason
        @trigger \disconnect
        @connected = no
    @connect! if not @connecting

LongPolling::put-raw = (msg, path, callback) ->
    __ = @
    # log = get-logger "PUT_RAW"


    try
        throw '_id field missing' if msg._id is null
        throw 'not connected' if not @connected
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

        # log "initiating new request: ", request-id

        req = http.request options, (res) ->
            res.on \data, (data) ->
                # log "got data: ", data
                try
                    callback null, unpack data
                catch
                    # log "CAN NOT UNPACK DATA: ", data
                    # log "err: ", e
                    callback e, null

            res.on \error, ->
                # log "#{request-id} Response Error: ", err
                throw "RES.ON ERROR???"

            /*
            res.on \close, ->
                # INFO: This handler is fired on a successfull communication end
                # in Espruino, not in Node.js
            */

        req.on \error, (err) ->
            # called when we closed server with Ctrl+C
            # log "#{request-id} Request Error: ", err
            __.comm-err err, callback

        req.write content-str
        req.end!

    catch err
        # log "raw-get has exception: ", err
        __.comm-err err, callback


LongPolling::connect = (next-step) ->
    __ = @
    # log = get-logger \CONNECT
    @connecting = yes

    interval = @retry-count * @retry-interval
    interval = @max-interval if interval > @max-interval
    @retry-count++

    # log "retrying in #{interval}ms..." if interval > 0
    <- sleep interval

    # log "Trying to connect to server..."
    err, data <- __.get-raw __.settings.path.info, {hello: "world"}
    try
        throw "connection error" if err
        /*
        if data.aktos is \Welcome
            # log "connected to aktos device server"
        else if data.couchdb is \Welcome
            # log "connected to CouchDB"
        else
            throw "unknown server!"
        */
        #log "Connection seems ok, starting all tasks..."
        <- sleep 0
        __.retry-count = 0
        __.connected = yes
        __.connecting = no
        __.receive-loop!
        <- sleep 0
        __.trigger \connect, data
        <- sleep 0
        next-step!
    catch
        #console.log "LongPolling: Connect error : ", e
        <- sleep 10ms # sleep for no reason
        __.connecting = no
        __.connect!



LongPolling::receive-loop = ->
    __ = @
    # log = get-logger \RECEIVE_LOOP

    # log "started..."
    <- :lo(op) ->
        err, res <- __.get-raw __.settings.path.changes, {since: \now, feed: \longpoll}
        if err
            # log "stopping receive loop: ", err
            # error handlers and reconnection stuff
            # is triggered in @get-raw and @put-raw already
            # so nothing to do here...
            return op!
        else
            # log "got data: ", pack res
            <- sleep 0
            __.trigger \data, res
            <- sleep 1500ms
            lo(op)
