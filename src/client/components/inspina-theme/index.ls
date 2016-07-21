component-name = "inspina-theme"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-menu"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    data: ->
        is-selected: (url, selected) ->
            x = url is selected
            console.log "url: ", url
            console.log "selected", selected
            x
        is-selected-here: (sub-menu,selected) ->
            selected in [..url for sub-menu]

component-name = "inspina-right"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-header"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-content"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-footer"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
