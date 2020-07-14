require! 'aea/packing': {merge}
require! 'aea/sleep': {sleep}
require! 'aea/vlogger': {VLogger}
require! 'dcs/src/signal': {Signal}
require! 'actors/ractive-actor': {RactiveActor}

Ractive.components['ack-button'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    oninit: ->
        if @get \class
            if that.index-of(\transparent)  > -1
                @set \transparent, yes

        @actor = new RactiveActor this, 'ack-button'
        @doing-watchdog = new Signal!

    onrender: ->
        logger = new VLogger this, \ack-button

        @button-timeout = if @get \timeout
            that
        else
            6_000ms

        orig-tooltip = @get \tooltip

        set-button = (mode, message) ~>
            @set \state, mode
            message = if message then " |!| #{message}" else ''
            @set \tooltip, "#{orig-tooltip}#{message}"
            unless mode is \doing
                @doing-watchdog.go!

        if @actor.default-topic
            @actor.c-log "here is default route: ", @actor.default-route

        @on do
            _click: (ctx) ->
                if @get(\state) is \doing
                    logger.cwarn "ack-button prevents multiple click.
                        We shouldn't see this message as 'disabled' state
                        should have taken care of this problem."
                    return

                const c = ctx.getParent yes
                c.refire = yes
                c.actor = @actor

                val = @get \value
                @doing-watchdog.reset!
                @set \tooltip, orig-tooltip

                #@actor.c-log "firing on-click, default route:", @actor.default-route
                @fire \click, c
                # stop the event propogation
                return false

            state: (ctx, state) ->
                @state state

        @state = (state) ~>
            switch state
                when \done =>
                    set-button \done

                when \done... =>
                    set-button \done
                    <~ sleep 3000ms
                    set-button \normal

                when \normal =>
                    set-button \normal

                when \doing =>
                    set-button \doing
                    @set \selfDisabled, yes
                    timeout <~ @doing-watchdog.wait @button-timeout
                    @set \selfDisabled, no
                    if timeout
                        msg = "Button is timed out."
                        #logger.error msg
                        set-button \error, msg

        @error = (msg, callback) ~>
            logger.error msg, callback
            set-button \error, (msg.message or msg)

        @warn = (msg, callback) ~>
            try
                console.warn msg.message
                set-button \error, msg.message
            catch
                console.error e

        @info = (msg, callback) ~>
            #logger.info msg, callback
            PNotify.info do
                title: msg.title or "Info"
                text: (msg.message or msg)

            set-button \normal

        @yesno = (msg, callback) ~>
            logger.yesno msg, callback
            set-button \normal

        @heartbeat = (duration) ~>
            logger.clog "ack-button received a heartbeat" + if duration => ": #{that}" else "."
            @doing-watchdog.heartbeat duration
            @set \heartbeat, yes
            <~ sleep 200ms
            @set \heartbeat, no

        if @get \auto
            logger.clog "auto firing ack-button!"
            @fire \_click

    onteardown: ->
        @doing-watchdog.go!

    data: ->
        tooltip: ''
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
        self-disabled: no
        enabled: yes
        state: ''
        transparent: no
        heartbeat: no
