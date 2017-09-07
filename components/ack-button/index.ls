require! 'aea': {merge, sleep, VLogger}
require! 'dcs/browser': {Signal}

# for debugging reasons
require! 'aea':{pack}

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        if @get \class
            if that.index-of(\transparent)  > -1
                @set \transparent, yes

    onrender: ->
        @doing-watchdog = new Signal!
        logger = new VLogger this, \ack-button

        @button-timeout = if @get \timeout
            that
        else
            3_200ms

        set-button = (mode, message) ~>
            @set \state, mode
            @set \tooltip, message
            unless mode is \doing
                @doing-watchdog.go!

        @on do
            click: ->
                val = @get \value
                @doing-watchdog.reset!
                @set \tooltip, ""
                @fire \buttonclick, {}, val

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
                            logger.error msg
                            set-button \error, msg

        @error = (msg, callback) ~>
            logger.error msg, callback
            set-button \error, (msg.message or msg)

        @info = (msg, callback) ~>
            logger.info msg, callback
            set-button \normal

        @yesno = (msg, callback) ~>
            logger.yesno msg, callback
            set-button \normal

        @heartbeat = (duration) ~>
            logger.clog "ack-button received a heartbeat: #{duration}"
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
