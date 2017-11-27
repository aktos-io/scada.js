export class RactiveVar
    (@ractive, @name) ~>

    observe: ->
        @_observe-handle = @ractive.observe @name, ...arguments

    set: ->
        silent = (try arguments.1.silent) or false

        @_observe-handle?.silence! if silent
        @ractive.set @name, ...arguments
        @_observe-handle?.resume! if silent
