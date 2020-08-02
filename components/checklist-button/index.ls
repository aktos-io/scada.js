Ractive.components['checklist-button'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    data: ->
        completed: no
        disabled: no
