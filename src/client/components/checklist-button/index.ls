component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    data: ->
        completed: no
        disabled: no
