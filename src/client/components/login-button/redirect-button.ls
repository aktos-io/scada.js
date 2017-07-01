require! 'aea':{sleep}

Ractive.components['redirect-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('redirect-button.pug')
    isolated: yes
    onrender: ->
        redirect-delay = @get \redirect-delay

        i = 0
        <~ :lo(op) ~>
            @set \information, "(#{redirect-delay - i})"
            <~ sleep 1000ms
            return op! if ++i >= redirect-delay
            lo(op)
        @set \information, ""
        @find-component \a .fire \click
