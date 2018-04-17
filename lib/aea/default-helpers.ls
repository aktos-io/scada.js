prelude = require \prelude-ls
Ractive.defaults._ = prelude
require! './formatting': {unix-to-readable}
Ractive.defaults.unix-to-readable = unix-to-readable

window.find = prelude.find
window.PNotify = require 'pnotify/dist/umd/index.js' .default

# math.js settings
# ----------------------------------------------------------
window.math = Ractive.defaults.math = math = require 'mathjs'
for <[ adet TL USD EURO ]>
    math.create-unit ..

"""
math.config do
    number: \BigNumber
    precision: 6digits
"""

window.do-math = Ractive.defaults.do-math = (expression) ->
    exact = math.eval expression
    display = math.format exact, 6_digits
    float = parse-float display
    return {display, float, exact}

window.has-unit = Ractive.defaults.has-unit = (expression, unit) ->
    try
        math.eval "#{expression} to #{unit}"
        return yes
    catch
        return no

# kind of tests
math.eval "(0.0288 m^2) * 1"
