require! 'aea': {merge, sleep}
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
        __ = @
        @doing-watchdog = new Signal!
        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility

        @button-timeout = if @get \timeout
            that
        else
            2_000ms

        @observe \tooltip, (new-val) ->
            @set \reason, new-val

        @on do
            click: ->
                val = @get \value
                @doing-watchdog.reset!
                @set \tooltip, ""
                @fire \buttonclick, {}, val

            state: (_event, s, msg, callback) ->
                self-disabled = no

                if s in <[ done ]>
                    @set \state, \done

                if s in <[ done... ]>
                    @set \state, \done
                    <~ sleep 3000ms
                    if @get(\state) is \done
                        @set \state, ''

                if s in <[ done done... ]>
                    @doing-watchdog.go!

                if s in <[ normal ]>
                    @doing-watchdog.go!
                    @set \state, \normal

                if s in <[ doing ]>
                    @set \state, \doing
                    self-disabled = yes
                    reason <~ @doing-watchdog.wait @button-timeout
                    if reason is \timeout
                        @error "button timed out!"

                @set \selfDisabled, self-disabled

                if s in <[ error ]>
                    console.warn "scadajs: Deprecation: use \"ack-button.fire \\error\" instead"
                    @fire \error, msg, callback

        @error = (msg, callback) ~>
            console.log "ack-button error: #{pack msg}"
            @doing-watchdog.go!

            msg = if typeof! msg is \String
                {message: msg}
            else if not msg
                {message: '(message is empty)'}
            else
                msg

            msg = msg `merge` {
                title: msg.title or 'Error'
                icon: "warning sign"
            }
            action <~ logger.fire \showDimmed, {}, msg, {-closable}

            @set \state, \error
            @set \reason, msg.message
            @set \selfDisabled, no

            #console.log "error has been processed by ack-button, action is: #{action}"
            callback action if typeof! callback is \Function

        @info = (msg, callback) ~>
            @doing-watchdog.go!
            msg = if typeof! msg is \String
                {message: msg}
            else if not msg
                {message: '(message is empty)'}
            else
                msg

            msg = msg `merge` {
                title: msg.title or 'Info'
                icon: "info circle"
            }
            action <- logger.fire \showDimmed, {}, msg, {-closable}
            #console.log "info has been processed by ack-button, action is: #{action}"
            callback action if typeof! callback is \Function

        @yesno = (msg, callback) ~>
            @doing-watchdog.go!
            msg = if typeof! msg is \String
                {message: msg}
            else if not msg
                {message: '(message is empty)'}
            else
                msg

            msg = msg `merge` {
                title: msg.title or 'Yes or No'
                icon: "map signs"
            }
            action <- logger.fire \showDimmed, {}, msg, {-closable, mode: \yesno}
            #console.log "yesno dialog has been processed by ack-button, action is: #{action}"
            callback action if typeof! callback is \Function


        @heartbeat = (duration) ~>
            console.log "ack-button received a heartbeat: #{duration}"
            @doing-watchdog.heartbeat duration
            @set \heartbeat, yes
            <~ sleep 200ms
            @set \heartbeat, no

        if @get \auto
            console.log "auto firing ack-button!"
            @fire \click

    onteardown: ->
        @doing-watchdog.go!

    data: ->
        __ = @
        reason: ''
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
