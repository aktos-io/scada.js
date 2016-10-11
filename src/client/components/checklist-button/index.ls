component-name = "checklist-button"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    data: ->
        completed: no
        disabled: no 
