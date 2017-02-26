Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    oninit: ->
        __ = @
        @set \curr, '#/' if (@get \curr) is void

        do function hashchange
            hash = window.location.hash
            hash = '/' unless hash
            __.set \curr, hash

        $ window .on \hashchange, -> hashchange!

    data: ->
        curr: '#/'
