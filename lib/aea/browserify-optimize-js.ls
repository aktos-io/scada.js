require! 'through2': through
require! 'optimize-js'

module.exports = (file) ->
    through (buf, enc, next) ->
        content = buf.to-string \utf8
        this.push(optimize-js content)
        next!
