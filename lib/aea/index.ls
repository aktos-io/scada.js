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

shajs = require 'sha.js'
hash = (str) ->
    sha = shajs \sha256
    sha.update str, 'utf-8' .digest \hex

# Hash mini tests:
_test1 = hash "hello"
_test2 = hash "hello2"
_test3 = hash "hello"
if _test1 isnt _test3
    throw new Error "hash function doesn't work correctly!"

is-nodejs = ->
    if typeof! process is \process
        if typeof! process.versions is \Object
            if typeof! process.versions.node isnt \Undefined
                return yes
    return no

# get file extension
ext = (.split('.').pop!?.to-lower-case!)

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
    ext
    hash
}
