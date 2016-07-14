require! 'aea':{
    sleep, wait-for, timeout-wait-for, go, is-waiting
    merge, unpack, pack, repl, config
}

require! Wifi
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

gen-random-id = (digit) ->
    if not digit
        digit = 3
    Math.floor (Math.random! * Math.pow 10, digit)

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

LongPolling::send = (msg, callback) ->
    @send-raw {data: msg}, callback

LongPolling::send-ack = (callback) ->
    @send-raw {ack: "Mahmut"}, callback

LongPolling::send-raw = (msg, callback) ->
    __ = @
    content = msg `merge` @content
    conn-inf = @mk-opts content
    console.log \- * 20
    post-request-id = gen-random-id 3
    console.log "New POST request: ", post-request-id
    req = @http.request conn-inf, (res) ->
        res.on \data, (data) ->
            got-data = unpack data
            console.log "POST: #{post-request-id} HTTP> ", got-data
            console.log "post requestine data gelince : ", process.memory!
            if got-data.ack
                #console.log "ACK arrive: ", got-data.ack
                try
                    callback!
            if got-data.data
                #console.log "ACK arrive: ", got-data.ack
                try
                    callback!

        res.on \error, ->
            console.log "Error: #{post-request-id} ... WTF"
        res.on \close, ->
            console.log "Request: #{post-request-id} closed by server.."

    req.on \error, (err) ->
        __.trigger \error, err, callback
        callback err.message

    req.write (pack content)
    req.end!
    console.log "post requesti acildiktan sonra : ", process.memory!

load-code = void
LongPolling::send-get = (opts, callback) ->
    __ = @
    content = @content
    opts = opts `merge` {method: 'GET', headers: null}
    conn-inf = @mk-opts content, opts
    get-request-id = gen-random-id 3
    console.log "New GET request: #{get-request-id}"
    req = @http.get conn-inf, (res) ->
        res.on \data, (data) ->
            console.log "GET: #{get-request-id} have DATA: ", data, typeof data, data.length
            load-code := data
            #TODO: trigger something
            #callback!
            console.log "get requestine data gelince : ", process.memory!
            go \call-error

    req.on \error, (err) ->
        console.log "GET: #{get-request-id} have PROBLEM: ", err, " type: ", typeof err
        if is-waiting \call-error
            go \call-error, err
        else if err.message is 'no response'
            callback \try-connect-again

    console.log "get requesti acildiktan sonra : ", process.memory!
    reason, param <-timeout-wait-for 30000ms, \call-error
    if reason is 'has-event'
        console.log "Has event: ", param
        callback param
    else if reason is 'timed-out'
        console.log "Timeout...."
        callback \timeout

LongPolling::connect = (callback)->
    __ = @
    err <- @send-ack
    if not err
        do
            console.log "Connect function run correctly.."
            callback!
        do
            <- :lo(op) ->
                console.log "Receiver is starting asyncronously.."
                reason <- __.send-get {path: '/receive'}
                if not reason
                    console.log "I got data.. I am connecting again for new data: "
                    <- sleep 10000ms
                    lo(op)

                else if reason is \try-connect-again
                    console.log "I have a problem. I must be connect again: ", reason
                    lo(op)
    else
        console.log "Trying to connect again (2s)..."
        <- sleep 1000ms
        __.connect callback

LongPolling::on = (event, callback) ->
    @events[event] ++= callback

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
            console.log "Code is : ", code
            #eval code
    console.log "Initialy memory: ", process.memory!
    <- comm.connect
    <- sleep 20000ms
/*
    do
        <- :lo(op) ->

            if load-code
                #console.log "Evaling code,,"
                eval load-code
                #load-code = undefined
            else
                lo(op)
    #console.log "following code is starting..."
*/
/*

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

*/
