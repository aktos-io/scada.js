'''

## TODO: # Realtime Status:
-------------------

    waiting-init      : Waiting for first update
    normal            : Everything normal
    write-failed      : Write failed
    read-failed       : Read failed (when requested read on demand)
    heartbeat-failed  : Heartbeat failed

'''

require! 'actors': {RactiveIoProxyClient}

Ractive.components['sync'] = Ractive.extend do
    isolated: yes
    onrender: ->
        try
            @io-client = new RactiveIoProxyClient this, do
                timeout: 1000ms
                route: @get \route
                fps: @get \fps
                debug: @get \debug

            unless @get \readonly
                handle = @observe \value, ((_new) ~>
                    if @get \debug
                        @io-client.log.debug "Value is: ", _new
                    @io-client.write _new
                    ), {init: off}

            @io-client.on \error, (err) ~>
                console.warn "Proxy client received error: ", err, "(thus setting value to undefined.)"
                @fire \error, {}, err
                handle?.silence!
                @set \value, undefined
                handle?.resume!

            @io-client.on \read, (res, msg) ~>
                #console.log "we read something: ", res
                @fire \read, {}, res
                if @get \debug
                    console.log "Value read by #{@get 'route'} is: ", res
                handle?.silence!
                @set \value, res
                @set 'msg-timestamp', msg.timestamp
                @set 'value-timestamp', msg.data.ts
                handle?.resume!
        catch
            """WARNING: DO NOT REMOVE THIS TRY CATCH!!!"""
            console.warn "FIXME: CODING ERROR: ", e
    data: ->
        value: null
        'msg-timestamp': null
        'value-timestamp': null
