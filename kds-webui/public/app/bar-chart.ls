{split, take, join, lists-to-obj, Str} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

BarChart = Ractive.extend do
    template: '#bar-chart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-short-name: (name) ->
            "#{Str.take 6, name}..."

my-data =
    * name: "son kullanma tarihi geçmiş"
      amount: 15
    * name: "müşteri iade"
      amount: 80
    * name: "hatalı sipariş"
      amount: 23

simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]


ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: my-data
        simulate-data: simulate-data
    components:
        "bar-chart": BarChart
