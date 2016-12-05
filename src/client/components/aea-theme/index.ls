
component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-menu')
    isolated: yes
    data: ->
        expand: yes

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')
