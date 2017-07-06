require! 'prelude-ls': {split}
``
function hex2float (a) {return (a & 0x7fffff | 0x800000) * 1.0 / Math.pow(2,23) * Math.pow(2,  ((a>>23 & 0xff) - 127))}
``

data-types =
    # integer
    int: (x) -> parse-int x

    # hex representation of an integer number
    hex: (x) -> x.to-string 16 .to-upper-case!

    # hex representation of float number
    hexf: hex2float

    # the stored value in memory is 1000 times of actual value
    mili: (/1000)


example-memory-map =
    * name: \test-level1
      addr: \MD84
      data-type: \hexf

    * name: \test-level2
      addr: \MD85
      data-type: \hexf

export class MemoryMap
    (@memory-map, @opts) ->

    get-meaningful: (addr, value) ->
        for io in @memory-map
            if io['addr'] is addr
                return do
                    value: data-types[io.data-type] value
                    name: io.name

    get-addr: (io-name) ->
        if @opts.prefix
            io-name = split that, io-name .1

        for io in @memory-map
            if io['name'] is io-name
                return io.addr

    get-all-addr: ->
        [..addr for @memory-map]
