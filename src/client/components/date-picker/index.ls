{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

component-name = "date-picker"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"

    oninit: ->
        self = @

        @observe \value, (val) ->
            #console.log "val: ", val

        if (@get \id) is \will-be-random
            @set \id random.generate 7
            #console.log "picker id is: ", @get \id

        #console.log "date-time-picker starting..."
        <- sleep 0ms
        x = $ "\##{self.get 'id'}" .datetimepicker do
            # daysOfWeekDisabled: [6, 7]
            format: 'DD/MM/YYYY hh:mm'
            # format: 'X' // for unixtime stamp
            locale: 'tr'

        #console.log "x: " , x

        i = 0
        change-date = ->
            date-data = x.data!
            test = date-data.date
            console.log "test01: ", test
            testing = moment(test).format('X')
            console.log "testing: ", testing
            console.log "date is changed: ", date-data.date
            self.set \value, testing

        x.on "dp.change" , ->
            change-date!

        /*
        TODO:
            1- datetimepicker'ın girildiği date-data formatını UTC formatına çeviren fonksiyon yazılacak.
            2- UTC formatını datetimepicker'ın kabul ettiği formata çeviren fonksiyon yazılacak.
        */

    data: ->
        id: \will-be-random
