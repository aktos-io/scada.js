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
            success: ->
                callback!
            error: (XMLHttpRequest, textStatus, errorThrown) ->
                callback {error: XMLHttpRequest}
            dataType: "script"
            cache: true

# Simpler version of $.getScriptCached
``
// taken from https://stackoverflow.com/a/28002292/1952991

window.getScript = function(source, callback) {
    var script = document.createElement('script');
    var prior = document.getElementsByTagName('script')[0];
    script.async = 1;

    script.onload = script.onreadystatechange = function( _, isAbort ) {
        if(isAbort || !script.readyState || /loaded|complete/.test(script.readyState) ) {
            script.onload = script.onreadystatechange = null;
            script = undefined;

            if(!isAbort) { if(callback) callback(); }
        }
    };
    script.src = source;
    prior.parentNode.insertBefore(script, prior);
}
``

require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable

# useful for pretty formatting
window.oneDecimal = (x) -> parseFloat(Math.round(x * 10) / 10).toFixed(1)

require! 'on-idle'
window.on-idle = on-idle
require './ractive-synchronizer' .get-synchronizer
