{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

kds-data=
    * product-id: 2426
      amount:14
      reason:"sebep aa"
      date:2
    * product-id: 2426
      amount:18
      reason:"sebep bb"
      date:5
    * product-id: 2426
      amount:11
      reason:"sebep cc"
      date:5
    * product-id: 2426
      amount:40
      reason:"sebep dd"
      date:5
    * product-id: 2458
      amount:30
      reason:"ie bozuk"
      date:15
    * product-id: 2458
      amount:10
      reason:"ui bozuk"
      date:20

StackedBarChart = Ractive.extend do
    template: '#stackedchart'
    data:
        get-color: (order) ->
            colors = <[ red yellow green blue gray ]>
            console.log "color: ", colors[order]
            colors[order]

        get-graph-data:(val) ->
            console.log "getting graph data...val: ", val
            selected-id = val |> parse-int
            selected-list = [.. for kds-data when ..product-id is selected-id]

            r = []
            for i of selected-list
                console.log "i : ", i
                data-point = selected-list[i]

                # add cumulative starting coordinate to each data point
                data-point.start-x = sum [..amount for (take i, selected-list)]
                #console.log "sum: ", data-point.start-x

                r ++= [data-point]

            #console.log "r is: ", r
            r

ractive = new Ractive do
    el: '#example_container'
    template: '#mainTemplate'
    data:
        kds:''
        products:[9]
    components:
        stackedbarchart: StackedBarChart

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
