{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

component-name = "date-picker"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"


    /*
        Example Usage:
            date-picker(unix="{{ myUnixTime }}" display="{{ myDisplayTime }}" mode="{{ timePickerMode }}")
            unix -> eg: "1468575910000" for "Fri, 15 Jul 2016 09:45:10 GMT"
            display -> eg: "27.10.2016 13:15 (Istanbul)"
    */

    oninit: ->
        __ = @

        if (@get \id) is \will-be-random
            @set \id random.generate 7
            #console.log "picker id is: ", @get \id

        #console.log "date-time-picker starting..."
        <- sleep 0ms
        jq = $ "\##{__.get 'id'}"
        dp = jq.datetimepicker do
            # daysOfWeekDisabled: [6, 7]
            format: 'DD.MM.YYYY HH:mm'
            locale: 'tr'
            useCurrent: false
            showTodayButton: true
        #console.log "x: " , x

        dp-fn = $ "\##{__.get 'id'}" .data \DateTimePicker
        console.log "dp func: ", dp-fn

        dp.on "dp.change" , ->
            disp = jq.data!.date
            unix = moment(disp, 'DD.MM.YYYY HH:mm').unix! * 1000ms
            #console.log "unix time: ", unix
            __.set \unix, unix

        __.observe \unix, (val) ->
            console.log "unix val: ", val
            display = moment val .format 'DD.MM.YYYY HH:mm'
            console.log "display: ", display
            dp-fn.date display

    data: ->
        id: \will-be-random
