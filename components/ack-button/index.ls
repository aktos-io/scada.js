require! 'aea': {merge, sleep, VLogger}
require! 'dcs/browser': {Signal}
require! 'actors': {RactiveActor}

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
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

        set-button = (mode, message) ~>
            @set \state, mode
            @set \tooltip, message
            unless mode is \doing
                @doing-watchdog.go!

        if @actor.default-topic
            @actor.c-log "here is default topic: ", @actor.default-topic

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
                @set \tooltip, ""

                #@actor.c-log "firing on-click, default topic:", @actor.default-topic
                @fire \click, c
                # stop the event propogation
                return false

            state: (_event, s, msg, callback) ->
                switch s
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
            logger.info msg, callback
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
            @fire \click

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
