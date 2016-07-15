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


data1 = [[0,4],[1,8],[2,5],[3,10],[4,4],[5,16],[6,5],[7,11],[8,6],[9,11],[10,30],[11,10],[12,13],[13,4],[14,3],[15,3],[16,6]]
data2 = [[0,1],[1,0],[2,2],[3,0],[4,1],[5,3],[6,1],[7,5],[8,2],[9,3],[10,2],[11,1],[12,0],[13,2],[14,8],[15,0],[16,0]]


random = ->
    x= parse-int (Math.random! * 10)
    x

convert-to-flot =  ->
    #console.log "convert-to-flot1"
    x = [[x:random!, y:random!] for i from 0 to 15]
    y= sort-by (.x), x
    #console.log "y : ",y
    z=[[0.x,0.y] for y]
    #console.log "convert-to-flot1:", z
    z

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
        x: 5
        product-list: product-data1
        y: 1
        example-component:
            show: yes
        datepicker:
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
        if i > 3
            i:=0
        <- sleep 5000ms
        lo(op)
