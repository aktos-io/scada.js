require! 'aea':{
    sleep, wait-for, timeout-wait-for, go
    merge, unpack, pack, repl, config
}

require! Wifi

!function LongPolling settings
    __ = this
    @settings = settings
    @http = require \http
    @content =
        node: settings.id
    @events =
        error: []
        data: []
        receive: []
        connect: []
        disconnect: []
        code: []

LongPolling::mk-opts = (payload, settings) ->
    options =
        host: @settings.host
        port: @settings.port
        path: @settings.path
        method: @settings.method
        headers:
            "Content-Type": "application/json"
            "Content-Length": pack payload .length
    if settings
        options = options `merge` settings
    options

LongPolling::trigger = (name, ...event) ->
  [..apply @, event for @events[name] when typeof .. is \function ]

LongPolling::send = (...params, callback) ->
    [msg, opts] = params
    @send-raw {data: msg}, opts, callback

LongPolling::send-ack = (callback) ->
    @send-raw {ack: "Mahmut"}, callback

LongPolling::send-raw = (...params, callback) ->
    __ = @
    [msg, opts] = params
    content = msg `merge` @content
    if opts
        conn-inf = @mk-opts content, opts
    else
        conn-inf = @mk-opts content
    console.log \- * 20
    req = @http.request conn-inf, (res) ->
        res.on \data, (data) ->
            got-data = unpack data
            console.log "RESPONSE DATA HTTP> ", got-data
            #console.log "My path: ", conn-inf.path
            console.log "http data: ", got-data.data
            if got-data.code
                __.trigger \code, got-data.code
                try
                    callback!
            if got-data.ack
                #console.log "ACK arrive: ", got-data.ack
                try
                    callback!
            if got-data.data
                #console.log "ACK arrive: ", got-data.ack
                try
                    callback!


        res.on \error, ->
            console.log "Error:... WTF"
        res.on \close, ->
            console.log "Request is closed by server.."

    req.on \error, (err) ->
        __.trigger \error, err, callback
        callback err.message


    req.write (pack content)
    req.end!
    console.log process.memory!

LongPolling::connect = (callback)->
    __ = @
    err <- @send-ack
    if not err
        do
            console.log "Connect function run correctly.."
            callback!
        do
            <- sleep 2000ms

            <- :lo(op) ->
                console.log "!!!!!!Receiver is starting asyncronously.."
                err <- __.send {data: "I am receiver"}, {path: '/receive'}
                if not err
                    console.log "Burasi..."
                    <- sleep 4000ms
                    lo(op)
                else
                    console.log "Receiver error: ", err
    else
        console.log "Trying to connect again (2s)..."
        <- sleep 1000ms
        __.connect callback

LongPolling::on = (event, callback) ->
    @events[event] ++= callback

connect-to-wifi = (callback) ->
    do
        <- :lo(op) ->
            try
                wifi-setting = config.read setting.wifi
                essid = wifi-setting.essid
                throw if essid is void
                passwd = wifi-setting.passwd
                health = wifi-setting.health  # if health is 0 then wifi network is dead
            catch
                # connect to default essid
                essid = \aea
                passwd = \084DA789BF
                health = -1  # last resort
                console.log "Using default ESSID: ", essid

            #led-connected.att-blink!
            <- :lo(op) ->
                apn <- Wifi.scan
                for i in apn
                    console.log "Found ESSID: ", i.ssid
                    if i.ssid is essid
                        #led-connected.blink!
                        return op!
                console.log "ESSID '{#{essid}}' not found, searching again..."
                <- sleep 2000ms
                lo(op)

            <- :lo(op) ->
                console.log "trying to connect to wifi..."
                err <-! Wifi.connect essid, {password: passwd}
                console.log "connected? err=", err, "info", Wifi.getIP!
                if err is null
                    try
                        #console.log "trying connecting to server..."
                        #try-connecting-server!
                        return op!
                    catch
                        console.log "WTF:", e
                <- sleep 5000ms
                lo(op)
            callback! if typeof callback is \function

on-init = ->
    <- connect-to-wifi

    comm = new LongPolling do
        host: '192.168.2.107'
        id: 'abc123'
        port: 5656
        path: '/send'
        method: 'POST'

    comm
        ..on \receive, (data) ->
            console.log "I received following data: ", data

        ..on \error, (err, callback) ->
            console.log "COMM-ERR::: ", err.message

        ..on \connect, (info) ->
            console.log "Connected to server!!! Server info: ", info

        ..on \disconnect, ->
            console.log "Disconnected from server!"
        ..on \code (code) ->
            eval code
            try
                console.log "X is: ", x

    <- comm.connect

    console.log "following code is starting..."
    do
        <- sleep 1000ms

        <- :lo(op) ->
            #console.log process.memory!
            err <- comm.send do
                temperature: Math.random!
            if err
                console.log "We couldn't send data!"
            <- timeout-wait-for 10000ms, \temperature-measured
            lo(op)
