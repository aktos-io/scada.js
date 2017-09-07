require! 'aea': {merge, logger: Logger, pack, sleep}
require! 'dcs/browser': {Signal}

Ractive.components['logger'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        modal = $ @find '.ui.basic.modal'
        @logger = new Logger "Global Modal"
        selection-signal = new Signal!
        @on do
            # msg:
            #   title
            #   message
            # callback: is fired when modal is closed. parameter: action.
            show-dimmed: (ev, msg, callback) ->
                # print same message to the console for debugging purposes
                @logger.log msg
                
                selection-signal.reset!

                # DEPRECATION
                if typeof! callback is \Object
                    debugger
                    throw

                # Set nop if callback is undefined
                unless typeof! callback is \Function
                    callback = ->

                # default modal document options
                default-opts =
                    closable: yes
                    title: 'Modal'
                    buttons:
                        ok:
                            color: \green
                            text: \Okay
                            icon: \check

                # set message content
                # ------------------------------------
                switch typeof! msg
                    when \String => msg = {message: msg}
                    when \Object =>
                        unless msg.message
                            msg.message = JSON.stringify msg.message, null, 2

                msg = default-opts <<< msg

                # create buttons
                # ------------------------------------
                @set \buttons, for name of msg.buttons
                    msg.buttons[name].action = name
                    msg.buttons[name]

                # set message content
                # ------------------------------------
                @set do
                    dimmedMessage: msg.message
                    icon: msg.icon
                    dimmedTitle: msg.title

                modal.modal do
                    closable: msg.closable
                    on-hide: ~>
                        selection-signal.go \hidden
                        # this function must return `true`
                        # in order to let the modal to disappear
                        yes

                modal.modal \show

                timeout, action <~ selection-signal.wait
                @logger.log "selection made. action: ", action
                modal.modal \hide
                <~ sleep 0
                callback action

            selectionMade: (ctx, action) ->
                selection-signal.go action
