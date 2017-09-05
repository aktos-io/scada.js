require! './debug-log': {logger: Logger}

export class VLogger
    (@context)->
        # context is the ractive context
        @modal = @context.root.find-component \logger
        @logger = new Logger \VLogger
        @clog = @logger.log
        @cerr = @logger.err
        @cwarn = @logger.warn

    info: (msg, callback) ->
        m =
            message: msg
            title: \Info
            icon: \info
        @modal.fire \showDimmed, {}, m, {-closable}, callback

    error: (msg, callback) ->
        m =
            message: msg
            title: \Error
            icon: "warning sign"
        @modal.fire \showDimmed, {}, m, {-closable}, callback

    yesno: (msg, opts, callback) ->
        if typeof opts is \function
            callback = opts
            opts = {}

        opts <<< {-closable, mode: \yesno}

        m =
            message: msg.message or msg
            title: msg.title or 'Yes No'
            icon: "map signs"

        @modal.fire \showDimmed, {}, m, opts, callback
