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

export mm2px = (/ 25.4 * 96)
export px2mm = (* 1 / mm2px it)

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
        math.eval "#{expression} to #{unit}"
        return yes
    catch
        return no

# kind of tests
math.eval "(0.0288 m^2) * 1"
