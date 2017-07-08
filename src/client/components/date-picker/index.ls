require! 'aea/formatting': {unix-to-readable}

Ractive.components['date-picker'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        __ = @
        j = $ @find \.date-picker

        j.calendar do
            ampm: false
            text:
                days: ['Pz', 'P', 'S', 'Ç', 'P', 'C', 'Cts']
                first-day-of-week: 1
                months:
                    \Ocak
                    \Şubat
                    \Mart
                    \Nisan
                    \Mayıs
                    \Haziran
                    \Temmuz
                    \Ağustos
                    \Eylül
                    \Ekim
                    \Kasım
                    \Aralık
                monthsShort:
                    \Oca
                    \Şub
                    \Mar
                    \Nis
                    \May
                    \Haz
                    \Tem
                    \Ağu
                    \Eyl
                    \Ekm
                    \Ksm
                    \Arl
                today: 'Bugün'
                now: \Şimdi
                am: \ÖÖ
                pm: \ÖS

            on-change: (date, text, mode) ->
                unix-ms = date.get-time!
                unix = unix-ms / 1000
                __.set \unix, unix
                __.set \unix-ms, unix-ms
                __.set \buttonText, unix-to-readable unix-ms

        @observe \unix, (unix) ->
            try
                unix-ms = unix * 1000
                date = new Date unix-ms
                j.calendar "set date", date, update-input=yes, fire-change=no
                __.set \buttonText, unix-to-readable unix-ms

            catch
                console.warn "date-picker: ", e
                debugger

    data: ->
        buttonText: "Select Date"
