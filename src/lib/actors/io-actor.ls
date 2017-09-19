/*

IoActor is an actor that subscribes IoMessage messages

# usage:

    # create instance
    actor = new IoActor 'pin-name'

    # send something
    actor.send-val 'some value to send'

    # receive something
    actor.handle_IoMessage = (msg) ->
        message handler that is fired on receive of IoMessage

 */

require! './ractive-actor': {RactiveActor}
require! './filters': {FpsExec}
require! 'aea': {sleep}

context-switch = sleep 0

export class IoActor extends RactiveActor
    (ractive, name) ->
        super ractive, name

    action : ->
        @subscribe "ConnectionStatus"
        @log.log "IoActor is created with the following name: ", @name, "and ID: #{@id}"

    handle_ConnectionStatus: (msg) ->
        @log.log "Not implemented, message: ", msg

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
            fps.exec @send, _new, topic


        @on \data, (msg) ~>
            if msg.topic is topic
                handle.silence!
                @ractive.set keypath, msg.payload
                handle.resume!
