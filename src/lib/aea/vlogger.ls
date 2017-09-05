require! './debug-log': {logger: Logger}

export class VLogger
    (@context)->
        # context is the ractive context
        @modal = @context.root.find-component \logger
        @logger = new Logger \VLogger
        @clog = @logger.log
        @cerr = @logger.err
        @cwarn = @logger.warn

    info: (msg, opts, callback) ->
        if typeof opts is \function
            callback = opts
            opts = {}

        opts <<< {-closable}

        m =
            message: msg
            title: \Info
            icon: \info
        @modal.fire \showDimmed, {}, m, opts, callback

    error: (msg, opts={}, callback) ->
        if typeof opts is \function
            callback = opts
            opts = {}

        opts <<< {-closable}

        m =
            message: msg
            title: \Error
            icon: "warning sign"
        @modal.fire \showDimmed, {}, m, opts, callback

    yesno: (msg, opts, callback) ->
        if typeof opts is \function
            callback = opts
            opts = {}

        default-opts =
            closable: no
            buttons:
                * role: \cancel
                  color: \red
                  text: 'No'
                  icon: \remove

                * role: \ok
                  color: \green
                  text: 'Yes'
                  icon: \check

        opts = default-opts <<< opts

        m =
            message: msg.message or msg
            title: msg.title or 'Yes No'
            icon: "map signs"

        @modal.fire \showDimmed, {}, m, opts, callback
