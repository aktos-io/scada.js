{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

component-name = "date-picker"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

    oninit: ->
        if (@get \id) is \will-be-random
            @set \id random.generate 7
            #console.log "picker id is: ", @get \id

        @on do
            #console.log "date-time-picker starting..."
            self = @
            $ ->
                $ "\##{self.get 'id'}" .datetimepicker do
                    daysOfWeekDisabled: [0, 6]

    data: ->
        id: \will-be-random
