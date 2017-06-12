require! 'aea': {merge, sleep}
require! 'dcs/browser': {IoActor}

Ractive.components['rt-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        @actor = new IoActor (@get \topic)

    onrender: ->
        __ = @

        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility

        @on do
            click: ->
                @actor.send (@get \value), (@get \topic)

    data: ->
        __ = @
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
        enabled: yes
        state: ''
