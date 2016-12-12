component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        __ = @
        @on do
            toggleChecked: ->
                __.toggle \checked
    data: ->
        checked: no
        style: ''
