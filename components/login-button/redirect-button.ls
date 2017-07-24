require! 'aea':{sleep}

Ractive.components['redirect-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('redirect-button.pug')
    isolated: yes
    onrender: ->
        @on do
            click: ->
                @find-component \a .fire \click

        redirect-delay = @get \redirect-delay
        i = 0
        <~ :lo(op) ~>
            @set \information, "(#{redirect-delay - i})"
            return op! if ++i > redirect-delay
            <~ sleep 1000ms
            lo(op)
        @set \information, ""

        if redirect-delay > 0
            # FIXME: Possible bug of Ractive, removing sleep prevents `fire` from working
            <~ sleep 0ms
            @fire \click
