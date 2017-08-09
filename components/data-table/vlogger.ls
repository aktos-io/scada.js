export class VLogger
    (@context)->
        # context is the ractive context
        @logger = @context.root.find-component \logger

    info: (msg, callback) ->
        m =
            message: msg
            title: \Info
            icon: \info
        @logger.fire \showDimmed, {}, m, {-closable}, callback

    error: (msg, callback) ->
        m =
            message: msg
            title: \Error
            icon: "warning sign"
        @logger.fire \showDimmed, {}, m, {-closable}, callback


    clog: (msg) ->
        console.log "vlogger: ", msg
