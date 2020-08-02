require! 'aea': {sleep}

Ractive.components['text-button'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        button = @find-component \ack-button
        @on do
            _buttonclick: (ev, val) ->
                @fire \buttonclick, ev, (@get 'amount'), val


        <~ sleep 0
        @info = button.info
        @yesno = button.yesno
        @error = button.error


    data: ->
        amount: null
        value: null
        disabled: no
        enabled: yes
        inputType: "text"
        buttonType: "info"
