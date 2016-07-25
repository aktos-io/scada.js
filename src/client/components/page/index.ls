component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: no
    data: ->
        is-selected: (url) ->
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            return true if (url in ['', void, null]) and (@get \name) is '/'
            url is "\##{@get 'name'}"
