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
