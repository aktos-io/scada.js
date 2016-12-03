require! 'aea':{sleep}

component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: no
    data: ->
        is-selected: (url) ->
            __ = @
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            this-page = @get \name
            landing-page = @get 'landing-page'
            if this-page is '/' or landing-page
                if url in ['', void, null, '/']
                    @set \visible, true
                    return true

            first-part = url.substring 0, (this-page.length + 1)
            show-page = first-part is ('#' + this-page)

            @set \visible, show-page
            return show-page

        visible: no
