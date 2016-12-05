component-name = "checklist-button"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    data: ->
        completed: no
        disabled: no
