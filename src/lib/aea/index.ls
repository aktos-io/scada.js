require! {
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './debug-log': {debug-log, get-logger, logger, debug-levels}
    './packing': {pack, unpack, clone}
    './formatting': {unix-to-readable, readable-to-unix}
    './convert-units': {convert-units}
    './vlogger': {VLogger}
    './event-emitter': {EventEmitter}
}

require! 'prelude-ls': {chars, unchars, reverse}

export function assert (condition, message)
    unless condition
        message = message or "Assertion failed"
        if (typeof Error) isnt void
            throw new Error message
        throw message  # Fallback


is-nodejs = ->
    if typeof! process is \process
        if typeof! process.versions is \Object
            if typeof! process.versions.node isnt \Undefined
                return yes
    return no


export obj-copy = (x) -> JSON.parse JSON.stringify x

export dynamic-obj = (...x) ->
    o = {}
    val = x.pop!
    key = x.pop!

    #console.log "key, val: ", x, key, val
    if key
        o[key] = val
    else
        return val
    dynamic-obj.apply this, (x ++ o)

export attach = (obj, key, val) ->
    if key of obj
        obj[key].push val
    else
        obj[key] = [val]


``
// Copies a string to the clipboard. Must be called from within an
// event handler such as click. May return false if it failed, but
// this is not always possible. Browser support for Chrome 43+,
// Firefox 42+, Safari 10+, Edge and IE 10+.
// IE: The clipboard feature may be disabled by an administrator. By
// default a prompt is shown the first time the clipboard is
// used (per session).
function copyToClipboard(text) {
    if (window.clipboardData && window.clipboardData.setData) {
        // IE specific code path to prevent textarea being shown while dialog is visible.
        return clipboardData.setData("Text", text);

    } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
        var textarea = document.createElement("textarea");
        textarea.textContent = text;
        textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
        document.body.appendChild(textarea);
        textarea.select();
        try {
            return document.execCommand("copy");  // Security exception may be thrown by some browsers.
        } catch (ex) {
            console.warn("Copy to clipboard failed.", ex);
            return false;
        } finally {
            document.body.removeChild(textarea);
        }
    }
}
``

export tr-to-ascii = (x) ->
    _from = "çalışöğünisÇALIŞÖĞÜNİŞ"
    _to = "calisogunisCALISOGUNIS"

    exploded = chars x
    for ci of exploded
        for index, f of _from
            exploded[ci] = _to[index] if exploded[ci] is f
    unchars exploded

if make-tests=no
    tests =
        'ÖZDİLEK': "OZDILEK"
        "özdilek": "ozdilek"

    console.log "started tr-to-ascii tests"
    for w, c of tests
        if tr-to-ascii(w) isnt c
            console.log "tr-to-ascii of #{w} is #{tr-to-ascii w} but expecting #{c}"
            throw
    console.log "finished tr-to-ascii tests"



hex = (n) -> n.to-string 16 .to-upper-case!

ip-to-hex = (ip) ->
    i = 0
    result = 0
    for part in reverse ip.split '.'
        result += part * (256**i++)

    hex result

module.exports = {
    sleep, after, clear-timer
    merge
    logger,
    Logger: logger,
    pack, unpack, clone
    unix-to-readable, readable-to-unix
    assert
    obj-copy, dynamic-obj, attach
    copyToClipboard
    tr-to-ascii
    convert-units
    is-nodejs
    hex, ip-to-hex
    VLogger
    EventEmitter
}
