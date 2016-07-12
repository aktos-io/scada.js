{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

component-name = "date-picker"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

    oninit: ->
        console.log "datetime picker: ", $.datetimepicker
        /*
        $ '#datetimepicker11' .datetimepicker do
            days-of-week-disabled: [0, 6]
        */
