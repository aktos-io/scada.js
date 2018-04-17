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
                topic: @get \sync-topic
                fps: @get \fps

            unless @get \readonly
                handle = @observe \value, ((_new) ~>
                    #@io-client.log.log "Value is: ", _new
                    @io-client.write _new
                    ), {init: off}

            @io-client.on \error, (err) ~>
                console.warn "Proxy client received error: ", err, "(thus setting value to undefined.)"
                @fire \error, {}, err
                handle?.silence!
                @set \value, undefined
                handle?.resume!

            @io-client.on \read, (res) ~>
                #console.log "we read something: ", res
                @fire \read, {}, res
                if @get \debug
                    console.log "Value read by #{@get 'sync-topic'} is: ", res.curr
                handle?.silence!
                @set \value, res.curr
                handle?.resume!
                if res.curr is res.prev
                    console.warn "same data arrived????: ", res
        catch
            """WARNING: DO NOT REMOVE THIS TRY CATCH!!!"""
            console.warn "FIXME: CODING ERROR"
    data: ->
        value: null
