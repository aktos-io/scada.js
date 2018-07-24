prelude = require \prelude-ls
Ractive.defaults._ = prelude
window.find = prelude.find

# do-math
require! './do-math': {math, do-math, has-unit}
window.math = Ractive.defaults.math = math
window.do-math = Ractive.defaults.do-math = do-math
window.has-unit = Ractive.defaults.has-unit = has-unit
