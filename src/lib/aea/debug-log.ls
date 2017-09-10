# for debugging purposes
require! colors: {green, gray, yellow, bg-red, bg-yellow}
require! moment
require! 'prelude-ls': {map}
require! './event-emitter': {EventEmitter}

fmt = 'HH:mm:ss.SSS'

start-time = new moment

align-left = (width, inp) ->
    x = (inp + " " * width).slice 0, width

get-timestamp = ->
    # current time
    (new moment).format fmt

    # differential time
    #moment.utc(moment((new moment), fmt).diff(moment(startTime, fmt))).format(fmt)

get-prefix = (_source, color) ->
    color = gray unless color
    padded = align-left 15, "#{_source}"
    (color "[#{get-timestamp!}]") + " #{padded} :"

class LogManager extends EventEmitter
    @@instance = null
    ->
        return @@instance if @@instance
        super!
        @@instance := this
        @loggers = []

    register: (ctx) ->
        @loggers.push ctx


export class logger extends EventEmitter
    (source-name, opts={}) ->
        super!
        @source-name = source-name
        @mgr = new LogManager!

    get-prefix: (color) ->
        get-prefix @source-name, color

    log: (...args) ~>
        console.log.apply console, [@get-prefix!] ++ args

    log-green: ~>
        @log green ...

    err: (...args) ~>
        console.error.apply console, ([@get-prefix bg-red] ++ args)
        @trigger \err, ...args
        @mgr.trigger \err, ...args

    warn: (...args) ~>
        console.warn.apply console, [@get-prefix(bg-yellow), yellow('[WARNING]')] ++ args
