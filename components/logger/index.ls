require! 'aea': {merge, Logger, pack, sleep}
require! 'dcs/browser': {Signal, topic-match}
require! 'actors': {RactiveActor}

Ractive.components['logger'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        modal = $ @find '.ui.basic.modal'
        @logger = new Logger "Global Modal"
        @actor = new RactiveActor this, {name: "Global Modal"}
            ..subscribe 'app.log.**'

        @actor.on \data, (msg) ~>
            if msg.to `topic-match` 'app.log.**'
                action <~ @fire \showDimmed, {}, msg.data
                @actor.send-response msg, {action}

        if @get \debug
            @logger.mgr.on \err, (...args) ~>
                @push \debugErrorMessages, pack args

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
                        if typeof! msg.message in <[ Object Array ]>
                            msg.message = JSON.stringify msg.message, null, 2

                msg = default-opts <<< msg

                # create buttons
                # ------------------------------------
                @set \buttons, for name of msg.buttons
                    msg.buttons[name].action = name
                    msg.buttons[name]

                # set message content
                # ------------------------------------
                _message = if msg.message?stack
                    msg.message.message
                else
                    msg.message

                @set do
                    dimmedMessage: _message?.replace /\n\n/g, '<br /><br />'
                    icon: msg.icon
                    dimmedTitle: msg.title

                modal.modal do
                    closable: msg.closable
                    on-hide: ~>
                        selection-signal.go null, \hidden
                        # this function must return `true`
                        # in order to let the modal to disappear
                        yes

                modal.modal \show

                c = null
                if msg.template
                    # display the ractive template
                    c = new Ractive do
                        el: @find '#client-template'
                        template: that
                        data: msg.data

                timeout, action <~ selection-signal.wait
                @logger.log "selection made. action: ", action
                modal.modal \hide
                <~ sleep 0
                callback action, c?.get!
                <~ sleep 0
                c?.teardown!

            selectionMade: (ctx, action) ->
                selection-signal.go null, action

    data: ->
        debugErrorMessages: []
