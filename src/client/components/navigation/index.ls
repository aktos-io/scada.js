component-name = "navigation"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        @set \selected, '#/' if (@get \selected) is void

        do function hashchange
            hash = window.location.hash
            unless hash
                debugger
            else
                __.set \selected, hash 

        $ window .on \hashchange, -> hashchange!
