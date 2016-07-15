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
        self = @

        if (@get \id) is \will-be-random
            @set \id random.generate 7
            #console.log "picker id is: ", @get \id

        #console.log "date-time-picker starting..."
        <- sleep 0ms
        x = $ "\##{self.get 'id'}" .datetimepicker do
            # daysOfWeekDisabled: [6, 7]
            format: 'DD/MM/YYYY HH:mm'
            # format: 'X' // for unixtime stamp
            locale: 'tr'
            useCurrent: false
            showTodayButton: true
        #console.log "x: " , x

        unix-to-date = ->
            from-others-unix = self.get \unix
            my-date = new Date( from-others-unix )
            from-others = my-date.toLocaleString!
            console.log "unix date converted: ", from-others

        change-date = ->
            disp = x.data!.date
            unix = moment(disp, 'DD/MM/YYYY HH:mm').unix! * 1000ms
            #console.log "unix time: ", unix
            self.set \value, unix
            self.set \unix, unix

        x.on "dp.change" , ->
            change-date!

        self.observe \value, (val) ->
            #console.log "val: ", val

        self.observe \unix, (val) ->
            console.log "unix val: ", val
            unix-to-date!

    data: ->
        id: \will-be-random
