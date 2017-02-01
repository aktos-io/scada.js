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
                message = @get \message
                #ev.component.fire \state, \doing

                if pack(curr) is pack(prev)
                    __.set \editable, no
                    __.set \message, ""
                    return

                if message is ""
                    return ev.component.fire \state, \error, "Mesaj kısmı boş geçilemez!"

                log-item =
                    curr: curr
                    message: message
                    date: Date.now!
                    prev: prev

                log <- __.fire \valuechange, {component: ev}, log-item #log returns as curr

                if changelog.length is 0
                    changelog.unshift first-item =
                        curr: prev
                        message: "initial"
                        date: "(initial)"

                delete log.prev
                delete log-item.prev
                changelog.unshift (unpack pack (log or log-item))

                #ev.component.fire \state, \done...
                __.set \message, ""
                __.set \curr, curr
                __.set \changelog, changelog
                __.set \editable, no

            cancel: (ev) ->
                __.set \curr, (__.get \previous)
                __.set \editable, no
                __.set \message, ""

            show-popup: (ev, value) ->

                <- __.fire \displaylog, ev, value

    data: ->
        previous: ""
        editable: no
        curr: {}
        changelog: []
