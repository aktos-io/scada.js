# Prevent accidental reloads. ScadaJS is designed as a Single Page Application,
# so user should never need to reload the page.
unless (``/comment/.test(function(){/* comment */})``)
    # minified, prevent page from accidental reloading
    window.onbeforeunload = ->
        return "Note: SCADA is not intended to be reloaded"


# Pnotify
# -------------------------------------------
# see doc/available-libraries.md for examples
window.PNotify = require 'pnotify/dist/umd/PNotify'
window.PNotifyButtons = require 'pnotify/dist/umd/PNotifyButtons'
require 'nonblockjs/NonBlock.es5.js'
"""
To be able to use "non blocking" popups, `addClass: "nonblock"`
"""

require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable

require! 'on-idle'
window.on-idle = on-idle
require './ractive-synchronizer' .get-synchronizer
