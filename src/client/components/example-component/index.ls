component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    oninit: ->
        @observe \birth, ->
            @set \age, (2016 - (@get \birth))
