component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: no
    data: ->
        is-selected: (url) ->
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            this-page = @get \name
            if this-page is '/'
                if url in ['', void, null, '/']
                    debugger
                    return true
            else
                first-part = url.substring 0, (this-page.length + 1)
                return first-part is ('#' + this-page)
