require! 'aea':{pack, unpack, merge}
require! 'prelude-ls':{find, difference, keys}

Ractive.components['formal-field'] = Ractive.extend do
    template: require('./index.pug')
    isolated: no
    oninit: ->
        __ = @
        component-attributes = {}
        component-attributes = keys @component.attributeByName
        required-attr = <[ changelog value ]>

        readonly = if @partials.editForm then yes else no
        @set \readonly, readonly

        for name in component-attributes # attributes that start with '_' can be used, too.
            if name[0] is '_'
                required-attr.push name

        @set \extraAttributes, component-attributes `difference` required-attr

    onrender: ->
        __ = @
        extra-attr = @get \extraAttributes

        for let attr in extra-attr
            @observe attr, (_new) ->
                curr = __.get \curr
                curr[attr] = _new
                __.set \curr, curr

        @on do
            edit: ->
                if @get \readonly
                    @set \prev, unpack pack @get \curr
                    @set \editable, yes
                else
                    @set \editable, no

            accept: (event, ev) ->

                add-to-changelog = (log-item) ->
                    changelog = unpack pack __.get \changelog

                    if changelog.length is 0
                        changelog.unshift first-item =
                            curr: __.get \prev
                            message: "initial"
                            date: "(initial)"

                    delete log-item.prev
                    delete log-item.value
                    changelog.unshift log-item
                    return changelog

                curr = unpack pack __.get \curr
                prev = __.get \prev
                #ev.component.fire \state, \doing
                if pack(curr) is pack(prev)
                    __.set \editable, no
                    __.set \message, ""
                    return

                message = __.get \message
                if message is ""
                    return ev.component.error "Açıklama kısmı boş geçilemez!"

                log-item =
                    curr: curr
                    message: message
                    date: Date.now!
                    prev: prev
                    value: __.get \value

                <- __.fire \valuechange, {component: ev, add-to-changelog: add-to-changelog}, log-item #log returns as curr

                #ev.component.fire \state, \done...
                __.set \message, ""
                __.set \curr, curr
                __.set \changelog, (unpack pack (__.get \changelog))
                __.set \editable, no

            cancel: (event, ev) ->
                __.set \curr, (__.get \prev)
                __.set \editable, no
                __.set \message, ""

            show-popup: (event, ev, value) ->

                <- __.fire \displaylog, ev, value

    data: ->
        prev: ""
        editable: no
        curr: {}
        changelog: []
        message:""
        value: null
        readonly: yes
