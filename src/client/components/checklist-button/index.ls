Ractive.components['checklist-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    data: ->
        completed: no
        disabled: no
