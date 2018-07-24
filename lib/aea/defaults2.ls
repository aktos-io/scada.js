prelude = require \prelude-ls
Ractive.defaults._ = prelude
window.find = prelude.find

require! './formatting': {unix-to-readable}
window.unix-to-readable = Ractive.defaults.unix-to-readable = unix-to-readable

# do-math
require! './do-math': {math, do-math, has-unit}
window.math = Ractive.defaults.math = math
window.do-math = Ractive.defaults.do-math = do-math
window.has-unit = Ractive.defaults.has-unit = has-unit
