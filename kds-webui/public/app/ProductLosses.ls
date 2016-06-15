{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

kds-data=
    * product-id:2458
      amount:5
      reason:"hava sıcaklıgı"
      date:8
    * product-id: 2426
      amount:5
      reason:"hammadde bozuk"
      date:2
    * product-id:2458
      amount:15
      reason:"hava sıcaklıgı"
      date:6
    * product-id: 2426
      amount:25
      reason:"hammadde bozuk"
      date:4
    * product-id:2458
      amount:1
      reason:"hammadde bozuk"
      date:8
    * product-id: 2426
      amount:25
      reason:"hammadde bozuk"
      date:2

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

            console.log "r is: ", r
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
    get-soap!
    ractive.set \products products

get-kds-data = ->
    console.log "getting kds data..."
    selected-id = ractive.get 'kdsProductId' |> parse-int
    selected-list = [.. for kds-data when ..product-id is selected-id]
    ractive.set \kds selected-list
    return
    $.get "http://192.168.9.111/DemeterKds/api/productlosses/ProductLoss?productcode=#{ractive.get 'kdsProductId'}",(text) ->
        ractive.set \kds, convert-kds text

getSoap = ->

    return
    $.soap do
        url :"http://192.168.9.111:2222/Servis/DemeterWS/ProductsService.svc"
        SOAPAction : "http://tempuri.org/IProductsService/GetProductList"
        method : "GetProductList"
        data : {onlyOlds:false}
        appendMethodToURL : no
        namespaceURL : "http://tempuri.org/"
        success:(xml)->
            xml = xml.to-string!
            xml-new = xml.replace /a:/g, ''
            my-obj = []

            $ xml-new
                .find \GetProductListResponse
                .find \GetProductListResult
                .find \Product
                .each ->
                    my-obj.push $ this
            products.splice 0 , 2
            $ myObj .each ->
                x = $ @ .find 'name' .text!
                y = $ @ .find 'no' .text!
                y=parse-int y
                products.push do
                    id : y
                    name : x
        error : (SOAPResponse) ->
            alert "Urun listesi alınamadı.\n Servise Ulasılamıyor."

# js2ls ile duzenlenen kisim
(($) ->
  elem = document.getElementById 'myBar'
  elem2 = document.getElementById 'myProgress'
  elem2.style.display = 'block'
  originalXhr = $.ajaxSettings.xhr
  $.ajaxSetup {
    progress: ->
      console.log 'standard progress callback'
      return
    xhr: ->
      req = originalXhr!
      that$$ = this
      if req
        if typeof req.addEventListener is 'function'
          req.addEventListener 'progress', ((evt) ->
            width = evt.loaded * 100 / evt.total
            elem.style.width = width + '%'
            console.log width
            ($ '#myProgress').slideUp 2000 if width is 100
            return ), false
      req
  }
  return ) jQuery        