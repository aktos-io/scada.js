'''

Description
-----------------------------------
IoActor is an actor that subscribes a topic and keep its output in sync
in realtime.

Usage: (see "scada.js/components/sync")

'''
require! './ractive-actor': {RactiveActor}
require! 'dcs/browser': {FpsExec}

export class IoActor extends RactiveActor
    action : ->
        @subscribe "ConnectionStatus"
        @log.log "IoActor is created with the following name: ", @name, "and ID: #{@id}"

    sync: (keypath, topic, rate=20fps) ->
        unless topic
            @log.err 'Topic should be set first!'
            return

        @subscribe topic

        fps = new FpsExec rate
        first-time = yes
        handle = @ractive.observe keypath, (_new) ~>
            if first-time
                first-time := no
                return
            fps.exec @send, topic, _new


        @on \data, (msg) ~>
            if msg.topic is topic
                handle.silence!
                @ractive.set keypath, msg.payload
                handle.resume!
