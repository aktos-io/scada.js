prelude = require \prelude-ls
Ractive.defaults._ = prelude
require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable

window.find = prelude.find
window.PNotify = require 'pnotify/dist/umd/index.js' .default

# math.js settings
# ----------------------------------------------------------
window.math = Ractive.defaults.math = math = require 'mathjs'
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

"""
math.config do
    number: \BigNumber
    precision: 6digits
"""

# doMath()
window.do-math = Ractive.defaults.do-math = (expression) ->
    exact = math.eval expression
    display = math.format exact, 6_digits
    float = parse-float display
    return {display, float, exact}

'''
Usage of `doMath()` in Ractive:

    .ui.message
        .ui.input: input(value="{{x}}")
        | {{doMath(x).display}}

'''

# hasUnit()
window.has-unit = Ractive.defaults.has-unit = (expression, unit) ->
    try
        math.eval "#{expression} to #{unit}"
        return yes
    catch
        return no

# kind of tests
math.eval "(0.0288 m^2) * 1"
