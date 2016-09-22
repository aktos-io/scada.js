component-name = "checkbox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    data: -> 
        checked: no
