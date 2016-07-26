require! 'aea': {sleep}

component-name = "inspina-theme"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-menu"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        __ = @

        @set \selected, '#/' if (@get \selected) is void

        do function hashchange
            url = window.location.hash
            __.set \iselected, url
            __.set \selected, url

        $ window .on \hashchange, -> hashchange!

        @on do
            clicked-submenu: (args) ->
                #console.log "Clicked submenu:", args
                @set \submenuIndex, args.index.i
                @update!

            clicked: (args) ->
                #console.log "on-clicked: args: ", args
                context = args.context
                url = context.url
                #console.log "url", url
                if url
                    @set \iselected, url
                    @set \selected, url
                else
                    curr = @get \iselected
                    iselected = args.index.i
                    iselected = -1 if iselected is curr and
                    #console.log "not url; curr, iselected: ", curr, iselected
                    @set \iselected, iselected
    data: ->
        is-selected: (url, iselected) ->
            x = url is iselected
            #console.log "is-iselected says: ", url, iselected, url is iselected
            x

        is-selected-here: (sub-menu, iselected) ->
            iselected in [..url for sub-menu]

        open-submenu: (x) ->
            #console.log "open submenu param is: ", x
            submenu-index = @get \submenuIndex
            x is submenu-index

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
