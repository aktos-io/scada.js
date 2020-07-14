# math.js settings
# ----------------------------------------------------------
math = require 'mathjs'
export math

for <[ adet TL USD EURO ]>
    math.create-unit ..

/*
math.create-unit 'footpound', do
    definition: '1 ft lbf',
    base: 'TORQUE',
    aliases: ['knots', 'kts', 'kt']
*/
math.create-unit \adam, {aliases: <[ man ]>}
math.create-unit \adamsaat, do
    definition: '1 adam * h'
math.create-unit \adamdakika, do
    definition: '1 adam * minute'


_mm2px = ( / 25.4 * 96)
_px2mm = ( * 25.4 / 96)

export mm2px = (x) ->
    _x = {}
    switch typeof x
    | 'object' =>
        for i of x
            _x[i] = x[i] |> _mm2px
        _x
    |_ =>
        x |> _mm2px

export px2mm = _px2mm

"""
math.config do
    number: \BigNumber
    precision: 6digits
"""

export do-math = (expression) ->
    try
        exact = math.eval expression
        display = math.format exact, 6_digits
        float = parse-float display
        error = no
    catch
        error = e
    return {display, float, exact, error}

'''
Usage of `doMath()` in Ractive:

    .ui.message
        .ui.input: input(value="{{x}}")
        | {{doMath(x).display}}

'''

# hasUnit()
export has-unit = (expression, unit) ->
    try
        math.evaluate "#{expression} to #{unit}"
        return yes
    catch
        return no

if not has-unit "3m", "cm" => throw new Error "\"has-unit\" function works erroneously."
if has-unit "3m", "kg" => throw new Error "\"has-unit\" function works erroneously."

# kind of tests
math.evaluate "(0.0288 m^2) * 1"
