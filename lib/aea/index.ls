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

is-nodejs = ->
    if typeof! process is \process
        if typeof! process.versions is \Object
            if typeof! process.versions.node isnt \Undefined
                return yes
    return no

module.exports = {
    sleep, clear-timer
    createDownload
    merge
    Logger,
    pack, unpack, clone, diff
    unix-to-readable, readable-to-unix
    copyToClipboard
    is-nodejs
    VLogger
    download
}
