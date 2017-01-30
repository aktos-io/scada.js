require! 'aea':{pack, unpack, merge}
require! 'prelude-ls':{find}

Ractive.components['formal-field'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    oninit: ->
        __ = @
        component-attributes = unpack pack @get()

        /*
        for key, attr of component-attributes
            @set "#{key}", attr
        */
        curr = {}
        for key, attr of component-attributes
            unless ['previous', 'editable', 'changelog', 'curr'].indexOf(key) > -1
                a = {"#{key}": attr}
                curr `merge` a

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

                ev.component.fire \state, \doing

                if pack(curr) is pack(prev)
                    __.set \editable, no
                    return

                log-item =
                    curr: curr
                    date: Date.now!

                ack-button = __.find-all-components 'ack-button'
                for comp in ack-button
                    for attr in comp.component.attributes
                        if attr.value is 'formal-field-accept-button'
                            button = comp

                log <- __.fire \valuechange, {component: @, button: button}, curr, prev, log-item #log returns as curr

                if changelog.length is 0
                    changelog.unshift first-item =
                        curr: prev
                        date: "(initial)"


                changelog.unshift (log or log-item)

                ev.component.fire \state, \done...
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
