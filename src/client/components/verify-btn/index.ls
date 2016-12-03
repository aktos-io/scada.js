{sleep} = require "aea"

component-name = "verify-btn"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: yes
    oninit: ->
