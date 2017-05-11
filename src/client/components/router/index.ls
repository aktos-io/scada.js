require! page
require! 'aea': {sleep}

Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    onrender: ->
        __ = @

        scroll-to = (anchor) ->
            offset = $ "[href='\##{anchor}']" .offset!
            if offset
                $ 'html, body' .animate do
                    scroll-top: offset.top - 5px
                    , 500ms

        page '*', (ctx, next) ->
            _old = __.get \curr
            _new = ctx.path
            if _new isnt _old
                __.set \curr, _new
            <- sleep 20ms
            scroll-to ctx.hash if ctx.hash

        page!

        /*
        @set \curr, '#/' if (@get \curr) is void

        do function hashchange
            hash = window.location.hash
            hash = '/' unless hash
            __.set \curr, hash

        $ window .on \hashchange, -> hashchange!
        */

    data: ->
        curr: '/'
        root: 'showcase.html'
