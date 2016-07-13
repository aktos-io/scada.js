{sleep} = require "aea"
require! {
    'prelude-ls': {
        group-by
        sort-by
    }
}
require! components
require! 'aea': {PouchDB}

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

product-data =
    * name: "domates"
      supplier: "A_202"
      price: 25
      date: 12
      id: 47
    * name: "domates"
      supplier: "A_202"
      price: 23
      date: 17
      id: 47
    * name: "domates"
      supplier: "A_202"
      price: 24
      date: 11
      id: 47
    * name: "domates"
      supplier: "A_101"
      price: 22
      date: 45
      id: 47
    * name: "patates"
      supplier: "A_101"
      price: 10
      date: 15
      id: 12
    * name: "patates"
      supplier: "A_101"
      price: 14
      date: 18
      id: 12
    * name: "patates"
      supplier: "A_101"
      price: 12
      date: 26
      id: 12
    * name: "patates"
      supplier: "A_202"
      price: 10
      date: 15
      id: 12

convert-product-to-select-list= (product-data)->
    a = group-by (.name), product-data
    a = [{name: key, id:a[key]0.id} for key of a]
    #console.log "group-by data123: ",a
    a

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        db: db
        data1:convert-to-flot!
        data2:data2
        simulate-data:simulate-data
        x: 5
        product-list: product-data1
        y: 1

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
