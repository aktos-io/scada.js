component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('aea-menu.pug')
    isolated: yes
    data: ->
        expand: yes
