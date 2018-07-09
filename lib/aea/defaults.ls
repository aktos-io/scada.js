prelude = require \prelude-ls
Ractive.defaults._ = prelude
require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable

window.find = prelude.find

# Prevent accidental reloads. ScadaJS is designed as a Single Page Application,
# so user should never need to reload the page.
unless (``/comment/.test(function(){/* comment */})``)
    # minified, prevent page from accidental reloading
    window.onbeforeunload = ->
        return "hellooo"


# Pnotify
# -------------------------------------------
# see doc/available-libraries.md for examples
window.PNotify = require 'pnotify/dist/umd/PNotify'
window.PNotifyButtons = require 'pnotify/dist/umd/PNotifyButtons'

# do-math
require! './do-math': {math, do-math, has-unit}
window.math = Ractive.defaults.math = math
window.do-math = Ractive.defaults.do-math = do-math
window.has-unit = Ractive.defaults.has-unit = has-unit
