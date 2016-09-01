{sleep} = require "aea"

component-name = "verify-btn"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
