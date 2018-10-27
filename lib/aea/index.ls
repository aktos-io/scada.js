require! {
    './sleep': {sleep, clear-timer}
    './packing': {pack, unpack, clone, diff}
    './merge': {merge}
    './logger': {Logger}
    './formatting': {unix-to-readable, readable-to-unix}
    './vlogger': {VLogger}
}
require! './copy-to-clipboard': {copyToClipboard}
require! './file-download': {createDownload}
require! './download'
require! './html-encode-decode': {htmlEncode, htmlDecode}

is-nodejs = ->
    if typeof! process is \process
        if typeof! process.versions is \Object
            if typeof! process.versions.node isnt \Undefined
                return yes
    return no

module.exports = {
    sleep, clear-timer
    create-download
    merge
    Logger,
    pack, unpack, clone, diff
    unix-to-readable, readable-to-unix
    copy-to-clipboard
    is-nodejs
    VLogger
    download
    htmlEncode, htmlDecode
}
