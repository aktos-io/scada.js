component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    data: ->
        is-selected: (url) ->
            #console.log "PAGE: url: ", url, url is ''
            return true if (url is '') and (@get \name) is '/'
            url is "\##{@get 'name'}"
