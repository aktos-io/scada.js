component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: no
    data: ->
        is-selected: (url) ->
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            this-page = @get \name
            landing-page = @get 'landing-page'
            if this-page is '/' or landing-page
                if url in ['', void, null, '/']
                    return true

            first-part = url.substring 0, (this-page.length + 1)
            return first-part is ('#' + this-page)
