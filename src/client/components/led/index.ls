Ractive.components['led'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    data: ->
        type: \lightbulb
        state: off
