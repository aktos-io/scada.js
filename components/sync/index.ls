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

            handle = @observe \curr, ((_new) ~>
                @io-client.write _new
                ), {init: off}

            @io-client.on \error, (err) ~>
                console.warn "Proxy client received error: ", err
                @fire \error, {}, err

            @io-client.on \read, (res) ~>
                #console.log "we read something: ", res
                @fire \read, {}, res
                handle.silence!
                @set \curr, res.curr
                handle.resume!

        catch
            console.error "Error on sync component init: ", e
    data: ->
        curr: null
