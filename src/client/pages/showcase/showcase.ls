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
        "Son kullanma tarihi geÃ§miÅ"
        "MÃ¼Återi Ä°ade"
        "HatalÄ± SipariÅ"
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

    <- :lo(op) ->
        new-state = states[i++]
        #console.log "changing state: ", new-state
        ractive.set \buttonState, new-state
        if i > 3
            i:=0
        <- sleep 5000ms
        lo(op)
