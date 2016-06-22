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



get-return-production= (product-name) ->
    x = [..production for my-data when ..name is product-name].0
    #console.log " X is , ", x
    #console.log "DEBUG: ",  x.0.planned


my-data =
    * name: \Haydari
      production:
          * date: "12.02.2005"
            planned: 24
            produced: 12

          * date: "12.12.2012"
            planned: 55
            produced: 33

          * date: "12.12.2016"
            planned: 123
            produced: 97

    * name: \Rus
      production:
          * date: "10.02.2005"
            planned: 24
            produced: 12

          * date: "10.12.2012"
            planned: 49
            produced: 45

          * date: "10.12.2016"
            planned: 96
            produced: 87

    * name: \Ezme
      production:
          * date: "01.01.2012"
            planned: 9
            produced: 9

          * date: "02.03.2013"
            planned: 22
            produced: 19

          * date: "23.11.2016"
            planned: 23
            produced: 46


ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: my-data
        get-return-production: get-return-production
    components:
        "bar-chart": BarChart
