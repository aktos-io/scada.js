require! 'aea': {sleep}

component-name = "inspina-theme"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-menu"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        __ = @

        do function hashchange
            __.set \selected, window.location.hash

        $ document .ready ->
            $ window .on \hashchange, -> hashchange!

        @on do
            clicked: (args) ->
                console.log "on-clicked: args: ", args
                context = args.context
                url = context.url
                console.log "url", url
                if url
                    @set \selected, url
                else
                    curr = @get \selected
                    selected = args.index.i
                    selected = -1 if selected is curr and
                    console.log "not url; curr, selected: ", curr, selected
                    @set \selected, selected
    data: ->
        is-selected: (url, selected) ->
            x = url is selected
            #console.log "is-selected says: ", url, selected, url is selected
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
