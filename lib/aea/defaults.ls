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

# Cached version of $.getScript
window.getScriptCached = (url, callback) ->
    jQuery.ajax do
            type: "GET"
            url: url
            success: callback
            dataType: "script"
            cache: true

require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable
