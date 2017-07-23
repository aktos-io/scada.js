Ractive.components['btn'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    data: ->
        type: 'default'
        value: ''
        class: ''
        style: ''
        disabled: false
