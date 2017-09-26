require! 'aea': {pack, sleep}
require! 'dcs/browser': {Signal, Actor}

export class RactiveActor extends Actor
    (@ractive, opts={}) ->
        name = opts if typeof! opts is \String
        super "#{name}", opts

        @default-topic = "app.wid.#{that}" if @ractive.get \wid
        @name = @default-topic or opts.name or name

        # subscriptions
        @subscribe that if opts.subscribe

        # teleport signal is used for restoring a node after teleportation
        teleport-signal = new Signal

        @ractive.on do
            teardown: ~>
                @log.log "Ractive actor is being killed because component is tearing down"
                @kill \unrender

        orig-location = @ractive.target

        @on-topic @default-topic, (msg) ~>
            if typeof! msg.payload is \Object
                if \get of msg.payload
                    keypath = msg.payload.get
                    #@log.log "received request for keypath: '#{keypath}'"
                    #@log.log "responding for #{keypath}:", val
                    val = @ractive.get keypath
                    @send-response msg, {res: val}

                else if \cmd of msg.payload
                    switch msg.payload.cmd
                    | \ctx      => @send-response msg, {res: @ractive.get-context! }
                    | \target   => @send-response msg, {res: @ractive.target}
                    | \ractive  => @send-response msg, {res: @ractive}
                    | \teleport =>
                        teleport-signal.clear!
                        @send-response msg, do
                            ractive: @ractive
                        timeout <~ teleport-signal.wait
                        @ractive.insert orig-location
                    | \teleport-restore => teleport-signal.go!
                    |_ => @log.err "Not a known command:", msg.payload.cmd
            else
                debugger

        @on-topic 'app.router.changes', (msg) ~>
            if msg.payload.scene
                # put the node back only on scene changes
                teleport-signal.go!

        @send-wid = (msg) ~>
            if @default-topic
                @send that, msg

    c-log: ->
        @log.log ...arguments

    c-err: ->
        @log.err ...arguments

    c-warn: ->
        @log.warn ...arguments

    v-log: (doc, callback)->
        callback = (->) unless typeof! callback is \Function
        @send-request 'app.log.log', doc, callback

    v-err: (doc, callback)->
        callback = (->) unless typeof! callback is \Function
        @send-request 'app.log.err', doc, callback
