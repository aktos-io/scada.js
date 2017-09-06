require! 'aea': {merge, logger: Logger}

Ractive.components['logger'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        modal = $ @find '.ui.basic.modal'
        @logger = new Logger "Ractive Logger"

        @on do
            # msg:
            #   title
            #   message
            # callback: is fired when modal is closed. parameter: action.
            show-dimmed: (ev, msg, options, callback) ->
                #@logger.log "msg: ", msg, "options: ", options
                if typeof! options is \Function
                    callback = options
                    options = {}

                options = {+closable} <<< options

                if options.buttons
                    @set \buttons, that

                @set \mode, options.mode
                @set \icon, msg.icon

                @set \dimmedTitle, msg.title if msg.title
                @set \dimmedMessage, (msg.message or msg)
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
        buttons:
            * role: \ok     # 'ok' or 'cancel'
              color: \green
              text: \Okay
              icon: \check
            ...
