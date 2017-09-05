# for debugging purposes
require! colors: {green, gray, yellow}
require! moment

fmt = 'HH:mm:ss.SSS'

start-time = new moment

align-left = (width, inp) ->
    x = (inp + " " * width).slice 0, width

get-timestamp = ->
    # current time
    (new moment).format fmt

    # differential time
    #moment.utc(moment((new moment), fmt).diff(moment(startTime, fmt))).format(fmt)

get-prefix = (_source) ->
    padded = align-left 15, "#{_source}"
    (gray "[#{get-timestamp!}] ") + "#{padded} :"

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

    get-prefix: ->
        get-prefix @source-name

    log: (...args) ->
        if @level > debug-levels.silent
            console.log.apply console, [@get-prefix!] ++ args

    log-green: ->
        @log green ...

    err: (...args) ->
        if @level > debug-levels.silent
            console.error.apply console, [@get-prefix!] ++ args

    section: (section, ...args) ->
        if section in @sections
            pfx = "#{get-prefix!} |#{section}| :"
            console.log.apply console, [pfx] ++ args

    err-section: (section, ...args) ->
        if section in @sections
            console.error.apply console, [@get-prefix!] ++ args

    warn-section: (section, ...args) ->
        if section in @sections
            console.warn.apply console, [@get-prefix!] ++ args

    warn: (...args) ->
        console.warn.apply console, [@get-prefix!, yellow('[WARNING]')] ++ args
