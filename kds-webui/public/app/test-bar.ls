{split, take, join, lists-to-obj} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

kds-data=
    * product-id: 2426
      amount:14
      reason:"ıı bozuk"
      date:2
    * product-id: 2426
      amount:18
      reason:"aa bozuk"
      date:5
    * product-id: 2458
      amount:11
      reason:"ie bozuk"
      date:2
    * product-id: 2458
      amount:45
      reason:"ui bozuk"
      date:4

BarChart = Ractive.extend do
    template: '#chart'
    data:
        get-graph-data:(val) ->
            console.log "getting graph data...val: ", val
            selected-id = val |> parse-int
            selected-list = [.. for kds-data when ..product-id is selected-id]

ractive = new Ractive do
    el: '#example_container'
    template: '#donutTemplate'
    data:
        kds:''
        products:[9]
    components:
        barchart: BarChart

ractive.on do
    select : (event,id)->if event.hover then @set 'id',id else @set 'id',null
    get-kds-data: (event,id) -> ractive.set "kds", kds-data

products=
    * id: 2426
      name: "domates"
    * id: 2458
      name: "patates"

ractive.on 'complete', !->
    ractive.set \products products
