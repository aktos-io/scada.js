component-name = "navigation"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        @set \selected, '#/' if (@get \selected) is void

        do function hashchange
            __.set \selected, window.location.hash

        $ window .on \hashchange, -> hashchange!
