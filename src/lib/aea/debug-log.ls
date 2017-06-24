# for debugging purposes
require! colors: {green, gray, yellow}

start-time = new Date! .get-time!

export debug-log = (...x) ->
    console.warn yellow "Deprecated: Use logger class instead."
    console.log.apply this, [(new Date! .get-time! - start-time) + "ms : "]  ++ x

function align-left width, inp
    x = (inp + " " * width).slice 0, width

export get-logger = (debug-source, opts={}) ->
    (...x) ->
        console.warn yellow "Deprecated: Use logger class instead."
        return if debug-level is \silent
        if opts.incremental
            timestamp = (new Date! .get-time! - start-time) + "ms"
        else
            timestamp = Date!
        console.log.apply console, ["#{timestamp}:", (align-left 15, "#{debug-source}") + ":"] ++ x

export debug-levels =
    silent: 0
    normal: 1
    verbose: 2
    debug: 3

export class logger
    (source-name, opts={}) ->
        @source-name = source-name
        @level = debug-levels.normal
        @opts = opts
        @start-time = start-time
        @sections = []

    log: (...args) ->
        if @level > debug-levels.silent
            console.log.apply this, [@_get-prefix!] ++ args

    log-green: ->
        @log green ...

    debug-log: (...args) ->
        if @level >= debug-levels.debug
            console.warn "debug-log is depreciated. use log-section instead."
            @log ...args

    err: (...args) ->
        if @level > debug-levels.silent
            console.error.apply console, [@_get-prefix!] ++ args

    section: (section, ...args) ->
        if section in @sections
            pfx = "#{@_get-prefix!} |#{section}| :"
            console.log.apply console, [pfx] ++ args

    err-section: (section, ...args) ->
        if section in @sections
            console.error.apply console, [@_get-prefix!] ++ args

    warn-section: (section, ...args) ->
        if section in @sections
            console.warn.apply console, [@_get-prefix!] ++ args

    warn: (...args) ->
        console.warn.apply console, [@_get-prefix!, yellow('[WARNING]')] ++ args


    _get-timestamp: ->
        "#{new Date! .get-time! - @start-time}ms"

    _get-prefix: ->
        src-name = align-left 15, "#{@source-name}"
        (gray "#{@_get-timestamp!}: ") + "#{src-name} :"

if testing=no
    a = new logger \a
    a.log "hello there"
    # =>
    # 1ms: a               : hello there
