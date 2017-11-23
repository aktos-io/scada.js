require! 'through2': through
require! 'optimize-js'

module.exports = (file) ->
    through (buf, enc, next) ->
        content = buf.to-string \utf8
        try
            this.push(optimize-js content)
        catch _ex
            @emit 'error', _ex
            return
        next!
