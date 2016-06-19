{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

StackedBarChart = Ractive.extend do
    template: '#stackedchart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            console.log "color: ", colors[order]
            colors[order]

        get-graph-data:(data-list) ->
            /* this function returns list of data points
                in order to draw a stacked progress bar.

                input data format:

                    input-data =
                        * name: "My data 1"
                          amount: amount1
                        * name: "My data 2"
                          amount: amount2

                data format is as follows:

                    points =
                        * name: "My data 1"
                          amount: amount1
                          start-x: 0
                          center-x: start-x + amount1 / 2
                        * name: "My data 2"
                          amount: amount2
                          start-x: 0 + amount1
                          center-x: start-x + amount2 / 2
                        * name: "My data 3"
                          amount: amount3
                          start-x: 0 + amount1 + amount2
                          center-x: start-x + amount3 / 2
                        ...
            */
            console.log "data-list: " , data-list
            r = []
            for i in data-list
                console.log "i : ", i
                data-point = {name: i.name, amount: i.amount}

                # add cumulative starting coordinate to each data point
                data-point.start-x = sum [..amount for r]
                data-point.center-x = data-point.start-x + (data-point.amount / 2)
                console.log "sum: ", data-point.start-x

                r ++= [data-point]
                console.log "r: ", r
            return r



# ------------------------------------------------------------------------- #
                    # edit only below #
# ------------------------------------------------------------------------- #


convert-reason-to-sbc = (x) ->
    r = [name: ..reason, amount: ..amount for x]
    console.log "...: ", r
    r


get-return-reasons = ->
    names = <[
        Haydari
        Rus salata
        Mercimek
        İçli Köfte
        Sarma
        Dolma
        Patlıcan Ezme ]>

    reasons = <[
        SKT
        AAA
        BBB
        CCC
    ]>

    random = -> parse-int (Math.random! * 100)

    [{name: .., return-reasons: [{reason: .., amount: random!} for reasons]} for names]

return-reasons =
    * name: \Haydari
      return-reasons:
          * reason: "son kullanma tarihi geçmiş"
            amount: 15
          * reason: "müşteri iade"
            amount: 80
          * reason: "hatalı sipariş"
            amount: 23

    * name: "Rus Salatası"
      return-reasons:
          * reason: "son kullanma tarihi geçmiş"
            amount: 11
          * reason: "müşteri iade"
            amount: 35
          * reason: "hatalı sipariş"
            amount: 49

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        return-reasons: get-return-reasons!
        convert-reason-to-sbc: convert-reason-to-sbc
    components:
        'stacked-bar-chart': StackedBarChart
