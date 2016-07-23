component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    data: ->
        is-selected: (url) ->
            console.log "PAGE: url: ", url
            return true if (url in [void, null, '']) and (@get \name) is '/'
            url is "\##{@get 'name'}"
