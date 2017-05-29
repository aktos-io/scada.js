require! 'aea': {merge}

Ractive.components['logger'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        modal = $ @find '.ui.basic.modal'

        @on do
            # msg:
            #   title
            #   message
            # callback: is fired when modal is closed. parameter: action.
            show-dimmed: (event, msg, options, callback) ->
                callback = options unless callback
                options = {} unless typeof! options is \Object
                options = {+closable, mode: \ok} `merge` options

                @set \mode, options.mode
                @set \icon, msg.icon

                @set \dimmedTitle, msg.title
                @set \dimmedMessage, msg.message
                unless typeof! callback is \Function
                    callback = ->

                action-taken = null
                modal.modal do
                    closable: options.closable
                    on-deny: ->
                        action-taken := \denied
                        callback action-taken
                    on-approve: ->
                        action-taken := \approved
                        callback action-taken
                    on-hide: ->
                        callback \hidden unless action-taken

                modal.modal \show

    data: ->
        dimmed-title: "Upps!"
        dimmed-message: "(there should be a message here)"
        mode: null
        icon: null
