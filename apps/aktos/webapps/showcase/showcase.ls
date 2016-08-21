{sleep} = require "aea"
require! {
    'prelude-ls': {
        group-by
        sort-by
    }
}
require! components
require! 'aea': {PouchDB}
Ractive.DEBUG = /unminified/.test -> /*unminified*/

db = new PouchDB 'https://demeter.cloudant.com/cicimeze', skip-setup: yes


data1 = [[0,4],[1,8],[2,5],[3,10],[4,4]]
data2 = [[0,1],[1,0],[2,2]]


random = ->
    x= parse-int (Math.random! * 10)
    x

convert-to-flot =  ->
    x = [x:random!, y:random! for i from 0 to 5]
    y = sort-by (.x), x
    z = [[..x,..y] for y]
    #console.log "flot random data is: ", z
    z

simulate-bar-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]

get-page-url = ->
    url = window.location.href
simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"
    random = -> parse-int (Math.random! * 100)
    x = [random! for reasons]

utc-date = ->
    date = new Date!
    new Date date.getUTCFullYear!, date.getUTCMonth!, date.getUTCDate!, date.getUTCHours!, date.getUTCMinutes!, date.getUTCSeconds!
x = 2132312
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        page-url: get-page-url!
        my-unix-time: 1454277600000
        db: db
        test:
            date: utc-date!
            date2:new Date!
        simulate-data:simulate-data
        pie-data: simulate-data!
        x: 5
        y: 1
        example-component:
            show: yes
        datepicker:
            show: yes
            date1: 1469233440000  # 23.07.2016 03:24
        combobox:
            show: yes
            bound-selected: 47
            list1:
                * name: "domates"
                  id: 47
                * name: "patates"
                  id: 12
                * name: "kiraz"
                  id: 24
            list2:
                * name: "aaa domates"
                  id: 47
                * name: "bbb patates"
                  id: 12
                * name: "ccc kiraz"
                  id: 24
                * name: "ddd heyy"
                  id: 25

        flot:
            bound1: convert-to-flot!
            bound2: convert-to-flot!
            unbound1: convert-to-flot!
            unbound2: convert-to-flot!
            show: yes
        pie:
            show: yes
        bar:
            show: yes
            bound: simulate-bar-data!
            unbound: simulate-bar-data!
        button:
            show: yes
            run-console-log: ->
                console.log "showcase console log is running ...."
        menu:
            * title: "Showcase"
              icon:"fa fa-th-large"
              sub-menu:
                * title: "Bar Chart"
                  url: '#bar-chart.html'
                * title: "Line Chart"
                  url: '#line-chart.html'
                * title: "Interactive Table"
                  url: '#interactive-table.html'
            * title: "Order App."
              url: '#orders.html'
              icon: "fa fa-diamond"
            * title: "Stacked Bar Chart"
              icon: "fa fa-bar-chart-o"
              sub-menu:
                * title: "Bar Chart"
                  url: '#app/bar-chart.html'
                * title: "Line Chart"
                  url: '#231'
                * title: "Interactive Table"
                  url: '#interactive-table.html'
        datatable:
            settings:
                cols: "a, b, c"
            tabledata:
                * id: \aa-1
                  key: 'my key 1'
                  value: 'my value 1'
                * id: \aa-2
                  key: 'my key 2'
                  value: 'my value 2'
                * id: \aa-3
                  key: 'my key 3'
                  value: 'my value 3'
                * id: \aa-4
                  key: 'my key 4'
                  value: 'my value 4'

        datatable2:
            settings:
                cols: "ID, Key, Value"
                filters:
                    all: (docs, param, this_) ->
                        rows = [{id: ..id, cols: ['hello', ..key, ..value]} for docs]

                    some: (docs, param, this_) ->
                        rows = [{id: ..id, cols: ['hello', ..key, ..value]} for docs when "2" in ..key]
            tabledata:
                * id: \aa-1
                  key: 'my key 1'
                  value: 'my value 1'
                * id: \aa-2
                  key: 'my key 2'
                  value: 'my value 2'
                * id: \aa-3
                  key: 'my key 3'
                  value: 'my value 3'
                * id: \aa-4
                  key: 'my key 4'
                  value: 'my value 4'


        test-ack-button: (val) ->
            console.log "ack button in the main instance fired with value: ", val


x = 235484545
ractive.on do
    complete: ->
        i = 0
        states =
            \waiting
            \normal
            \error
            \okay

        unixs = [1554277600000,1354276600000,1254257600000,1054247600000]

        <- :lo(op) ->
            a = i++
            new-state = states[a]
            new-unix = unixs[a]
            #console.log "changing state: ", new-state
            ractive.set \buttonState, new-state
            ractive.set \myUnixTime, new-unix
            #console.log "myUnixTime: ", ractive.get \myUnixTime
            if i > 3
                i:=0
            <- sleep 5000ms
            lo(op)
