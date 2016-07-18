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
    x = [[x:random!, y:random!] for i from 0 to 6]
    y = sort-by (.x), x
    console.log "flot random data is: ", y
    y

product-data1 =
    * name: "domates"
      id: 47
    * name: "patates"
      id: 12
    * name: "kiraz"
      id: 24


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
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-unix-time: 1454277600000
        db: db
        data1:data1
        data2:data2
        test:
            date: utc-date!
            date2:new Date!
        simulate-data:simulate-data
        pie-data: simulate-data!
        x: 5
        product-list: product-data1
        y: 1
        example-component:
            show: yes
        datepicker:
            show: yes
            date1: 1469233440000  # 23.07.2016 03:24
        combobox:
            show: yes
        flot:
            show: yes
        pie:
            show: yes
        button:
            show: yes



ractive.on \complete, ->
    i = 0
    states =
        \waiting
        \normal
        \error
        \okey

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
