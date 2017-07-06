require! moment
require! 'prelude-ls': {
    split, last, map, take,
    drop, max, round, is-it-NaN
}
require! './packing': {clone}

export unix-to-readable = (unix) ->
    display = moment (new Date unix) .format "DD.MM.YYYY HH:mm"
    if display.match /date/ig
        '??'
    else
        display

export readable-to-unix = (display, format) ->
    unless format
        unix = moment(display, 'DD.MM.YYYY HH:mm').unix! * 1000ms
    else
        unix = moment(display, format).unix! * 1000ms

# -------------------------------------------------------------------------
#                           formatting
# -------------------------------------------------------------------------

strip = (.replace /\s/g, '')

left-zero-pad = (num-of-digits, value) ->
    max-digit = max "#{value}".length, num-of-digits
    result = if value?
        "#{"0" * num-of-digits}#{value}".slice -max-digit
    else
        null
    #console.log "left-zero: #{num-of-digits} .. #{value} ... #{result}"
    result


export parse-format = (format) ->
    unit-part = format.replace /\s*(#+\.?#*)\s*/, '' |> strip
    number-part = format.replace unit-part, '' |> strip

    if has-unit = unit-part.length > 0
        unit-on-left = if format.index-of(unit-part) is 0 then yes else no


    [integer-part, decimal-part] = number-part.split '.'
    max-digits = integer-part.length + decimal-part.length

    parsed =
        length-of:
            integer-part: integer-part.length
            decimal-part: decimal-part.length
            total: max-digits
        unit: void
        has:
            decimal: decimal-part.length > 0
            unit: has-unit

    if has-unit
        parsed <<< unit:
            text: unit-part
            is-on-left: unit-on-left
            is-on-right: not unit-on-left
    parsed


/*
parse-format '####.## km/sa'
parse-format '% ###.#'
parse-format '##.# °C'
parse-format '#.###### abc/m·s²'
parse-format '##.####'
*/

export display-format = (format, value) -->
    # see formatter-tests below
    if typeof! format is \String
        f = parse-format format
    else
        f = format

    to-fixed = (value, precision) ->
        power = Math.pow(10, precision or 0)
        String (Math.round(value * power) / power)

    to-double-fixed = (value, precision) ->
        # FIXME: this error value has to be added to the value in order
        # to round correctly
        err = (0.01 / (10 ** precision))
        x = to-fixed (value + err), (precision + 1)
        to-fixed x, precision

    try
        value = parse-float value
        throw if is-it-NaN value
        rounded-value = to-double-fixed value, f.length-of.decimal-part

        [integer-part, decimal-part] = "#{rounded-value}".split '.'
        decimal-part = decimal-part or 0
        #decimal-part = "#{"0" * f.length-of.decimal-part}#{decimal-part or 0}".slice -f.length-of.decimal-part

        number-text = left-zero-pad f.length-of.integer-part, integer-part
        if f.has.decimal
            number-text += "."
            number-text += take (f.length-of.decimal-part), "#{decimal-part}#{"0" * f.length-of.decimal-part}"
    catch
        number-text = "#{'-' * f.length-of.integer-part}#{"." if f.has.decimal}#{'-' * f.length-of.decimal-part}"
        rounded-value = null

    full-text = if f.has.unit
        if f.unit.is-on-right
            "#{number-text} #{f.unit.text}"
        else
            "#{f.unit.text} #{number-text}"
    else
        "#{number-text}"

    output =
        full-text: full-text
        rounded-value: rounded-value
        number-text: number-text
        format: f


# -----------------------------------------------------------------------
#                                    TESTS START HERE
# -----------------------------------------------------------------------
assert-str = (result, expected) ->
    if expected isnt result
        console.error """
            formatting.ls: Test failed: #{name}"
            EXPECTED: #{expected}
            RESULT  : #{result}
            """

formatter-tests =
  'simple formatting': ->
    f = display-format '#.### m/s'

    result = f 1234.123456 .full-text
    expected = '1234.124 m/s'
    assert-str result, expected

  'simple formatting2': ->
    f = display-format '####.### m/s'

    result = f 12.123456 .full-text
    expected = '0012.124 m/s'
    assert-str result, expected

    result = f 14.1 .full-text
    expected = '0014.100 m/s'
    assert-str result, expected

  'simple formatting3': ->
    f = display-format '###.##'
    assert-str f(116.60).full-text, '116.60'
    assert-str f(116).full-text, '116.00'
    assert-str f(63.009).full-text, '063.01'
    assert-str f(0.0049).full-text, '000.01'
    assert-str f(0.5044445999).full-text, '000.51'

start = Date.now!
test-count = 1 #15000
for i til test-count
    for name, test of formatter-tests
        test!
if test-count > 1
    console.log "formatting.ls: #{test-count} tests took: #{Date.now! - start} milliseconds..."
    # formatting.ls: 15000 tests took: 151 milliseconds...
