require! 'aea':{pack, unpack, merge}
require! 'prelude-ls':{find}

Ractive.components['formal-field'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    oninit: ->
        __ = @
        component-attributes = {}
        component-attributes = __.component.attributeByName
        /*
        for key, attr of component-attributes
            @set "#{key}", attr
        */
        curr = {}
        for key, attr of component-attributes
            unless ['changelog'].indexOf(key) > -1
                a = {"#{key}": attr.model.value}
                curr `merge` a
            else
                @set "#{key}", attr.model.value

        @set \curr, curr

    onrender: ->
        __ = @
        @on do
            edit: ->
                __.set \editable, yes
                __.set \previous, unpack pack (__.get \curr)

            accept: (ev) ->
                curr = unpack pack __.get \curr
                prev = __.get \previous
                changelog = __.get \changelog

                #ev.component.fire \state, \doing

                if pack(curr) is pack(prev)
                    __.set \editable, no
                    return

                log-item =
                    curr: curr
                    date: Date.now!

                log <- __.fire \valuechange, {component: ev}, curr, prev, log-item #log returns as curr

                if changelog.length is 0
                    changelog.unshift first-item =
                        curr: prev
                        date: "(initial)"


                changelog.unshift (unpack pack (log or log-item))

                #ev.component.fire \state, \done...
                __.set \curr, curr
                __.set \changelog, changelog
                __.set \editable, no

            cancel: (ev) ->
                __.set \curr, (__.get \previous)
                __.set \editable, no

            show-popup: (ev, value) ->

                <- __.fire \displaylog, ev, value

    data: ->
        previous: ""
        editable: no
        curr: {}
        changelog: []
