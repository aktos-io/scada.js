require! 'prelude-ls': {find, filter, empty, flatten, first}
require! './merge': {merge}
require! './packing': {pack}

default-units =
    * derived-unit: \kg
      amount: 1000
      base-unit: \gr
    * derived-unit: \gr
      amount: 1000
      base-unit: \mg
    * derived-unit: \kg
      amount: 10
      base-unit: \desi_gr

function ConversionException message, unit
    @message = "ConversionException: #{message}: #{pack unit}"
    @unit = unit
    @name = "ConversionException"

function ConversionTestException message
    @message = message
    @name = "ConversionTestException"

array-diff = (first, second) ->
    res = []
    for f in first
        try
            for s in second
                throw if pack(f) is pack(s)
            res.push f
    res

export function convert-units params
    params.in `merge` default-units
    all-units = flatten [[..derived-unit, ..base-unit] for params.in]
    conv-name = pack {from: params.from, to: params.to}
    recurse = (params) ->
        {in: coeff, from: source, to: target, debug: debug} = params
        return 1 if source is target

        #console.log "converting for #{conv-name} : #{source} -> #{target}"
        # TODO: optimize this function as it only needs to be called on first call among recursive calls
        for c in coeff
            matches = filter ((x) -> (x.derived-unit is c.derived-unit) and (x.base-unit is c.base-unit)), coeff
            if matches.length > 1
                throw new ConversionException "Duplicate unit definition", c


        if source not in all-units
            throw new ConversionException "No such source unit", source

        if target not in all-units
            throw new ConversionException "No such target unit", target

        debugger if debug
        # down conversion
        derived = filter (.derived-unit is source), coeff
        if not empty derived
            # maybe down conversion
            try
                return find (.base-unit is target), derived .amount
            catch
                for tu in derived
                    remaining = array-diff coeff, derived
                    try return tu.amount * recurse {in: remaining, from: tu.base-unit, to: target, debug: debug}

        # up conversion
        base = filter (.base-unit is source), coeff
        if not empty base
            # maybe up conversion
            try
                return 1 / find (.derived-unit is target), base .amount
            catch
                for tu in base
                    remaining = array-diff coeff, base
                    debugger if debug
                    try return (recurse {in: remaining, from: tu.derived-unit, to: target, debug: debug}) / tu.amount
        throw new ConversionException "Dead end", target
    recurse params

test-units =
    * derived-unit: \palet
      amount: 4
      base-unit: \koli

    * derived-unit: \koli
      amount: 6
      base-unit: \paket

    * derived-unit: \koli
      amount: 12
      base-unit: \desi

    * derived-unit: \koli
      amount: 24
      base-unit: \lira

    * derived-unit: \paket
      amount: 10
      base-unit: \gr

bad-units1 =
    * derived-unit: \paket
      amount: 10
      base-unit: \gr
    * derived-unit: \paket
      amount: 20
      base-unit: \gr

test-units2 =
    # test "down -> down -> up -> down" conversion
    * derived-unit: \koli
      amount: 20
      base-unit: \paket
    * derived-unit: \paket
      amount: 20
      base-unit: \gr


test-cases =
    # in test units
    * calculated: {in: test-units, from: \koli, to: \paket}
      expected: 6
    * calculated: {in: test-units, from: \koli, to: \gr}
      expected: 60
    * calculated: {in: test-units, from: \koli, to: \mg}
      expected: 60_000
    * calculated: {in: test-units, from: \desi, to: \koli}
      expected: 1 / 12
    * calculated: {in: test-units, from: \desi, to: \palet}
      expected: 1 / 12 / 4
    * calculated: {in: test-units, from: \koli, to: \koli}
      expected: 1
    * calculated: {in: test-units, from: \paket, to: \paket}
      expected: 1
    * calculated: {in: test-units, from: \paket, to: \kg}
      expected: 10 / 1000
    * calculated: {in: test-units, from: \palet, to: \lira}
      expected: 4 * 24
    * calculated: {in: test-units, from: \gr, to: \lira}
      expected: 0.4

    # in test units 2
    * calculated: {in: test-units2, from: \koli, to: \desi_gr}
      expected: 20 * 20 / 1000 * 10

exceptional-cases =
    # bad units
    * {in: bad-units1, from: \paket, to: \gr}  # duplicate units

    # test units
    * {in: test-units, from: \maket, to: \paket}  # no such source unit
    * {in: test-units, from: \paket, to: \maket}  # no such target unit

make-tests = no
if make-tests
    console.log "Begin CONVERT_UNITS testing..."
    # expected throwing exception for some test cases...
    for test in exceptional-cases
        test-name = "from #{test.from} to #{test.to}"
        try
            x = convert-units test
            throw new ConversionTestException """test failed for #{test-name}
                (expected throwing an exception, but returned #{x} instead)
                """
        catch
            if e.name is \ConversionException
                console.log "test passed: #{test-name}, message: #{e.message}"
            else
                console.error "test failed in #{test-name}:", e.message

    # normal conversion tests
    for test in test-cases
        test-name = "from #{test.calculated.from} to #{test.calculated.to}"
        try
            if test.expected isnt convert-units test.calculated
                throw new ConversionTestException """test failed while
                    converting #{test-name}, expected: #{test.expected},
                    calculated: #{convert-units test.calculated}
                    """
            else
                console.log "test passed: #{test-name}"
        catch
            console.error "test failed in #{test-name}", e
            #throw e.name

    console.log "End of CONVERT_UNITS testing..."
