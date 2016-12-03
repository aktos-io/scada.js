{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"


component-name = "date-picker"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.jade')


    /*
        Example Usage:
            date-picker(unix="{{ myUnixTime }}" display="{{ myDisplayTime }}" mode="{{ timePickerMode }}")
            unix -> eg: "1468575910000" for "Fri, 15 Jul 2016 09:45:10 GMT"
            display -> eg: "27.10.2016 13:15 (Istanbul)"
    */

    onrender: ->
        __ = @
        jq = $ @find \.date
        dp = jq.datetimepicker do
            # daysOfWeekDisabled: [6, 7]
            format: 'DD.MM.YYYY HH:mm'
            locale: 'tr'
            useCurrent: false
            showTodayButton: true
            ignoreReadonly: true
            side-by-side: yes

        #console.log "x: " , x

        dp-fn = jq.data \DateTimePicker
        #console.log "dp func: ", dp-fn

        dp.on "dp.change" , ->
            disp = jq.data!.date
            unix = moment(disp, 'DD.MM.YYYY HH:mm').unix! * 1000ms
            #console.log "unix time: ", unix
            __.set \unix, unix

        __.observe \unix, (val) ->
            #console.log "unix val: ", val
            display = moment (new Date val) .format 'DD.MM.YYYY HH:mm'
            #console.log "display: ", display
            dp-fn.date display
