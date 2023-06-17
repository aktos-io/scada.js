require! 'aea/formatting': {unix-to-readable}
require! moment

Ractive.components['date-picker'] = Ractive.extend do
    isolated: yes
    template: require('./index.pug')
    onrender: ->
        j = $ @find \.date-picker
        conv = if @get \ms => 1 else 1000

        min-date = if (@get \min-date) is "now"
            min-date = new Date! 
        else if (@get \min-date)? 
            min-date = new Date (@get \min-date)
        else
            null 

        j.calendar do
            ampm: false
            minDate: min-date
            text:
                days: <[ Pz Pt Sa Ça Pe Cu Cts ]>
                first-day-of-week: 1
                months:
                    ...<[ Ocak Şubat Mart Nisan Mayıs Haziran Temmuz ]>
                    ...<[ Ağustos Eylül Ekim Kasım Aralık ]>
                monthsShort: <[ Oca Şub Mar Nis May Haz Tem Ağu Eyl Ekm Ksm Arl ]>
                today: 'Bugün'
                now: \Şimdi
                am: \ÖÖ
                pm: \ÖS
            type: @get \mode
            inline: @get \inline

            on-change: (date, text, mode) ~>
                unix-ms = date.get-time!
                unix = unix-ms / conv
                @set \unix, unix
                @set \buttonText, unix-to-readable unix-ms
                @fire 'change', {}, moment(unix)

        @observe \unix, (unix) ->
            try
                unix-ms = unix * conv
                date = new Date unix-ms
                j.calendar "set date", date, update-input=yes, fire-change=no
                @set \buttonText, x=(unix-to-readable unix-ms, @get('mode'))
                @set \display, x

            catch
                console.warn "date-picker: ", e
                debugger

    data: ->
        buttonText: "Select Date"
        'min-date': null
        display: ""
        inline: false
