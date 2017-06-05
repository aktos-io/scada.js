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
                __.set \unix, date.get-time!

        @observe \unix, (unix) ->
            try
                date = new Date unix
                j.calendar "set date", date, update-input=yes, fire-change=no
            catch
                console.warn "date-picker: ", e
                debugger
