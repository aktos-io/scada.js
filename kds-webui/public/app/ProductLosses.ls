{split, take, join, lists-to-obj} = require 'prelude-ls'
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
    * product-id:2458
      amount:15
      reason:"hammadde bozuk"
      date:6
    * product-id: 2426
      amount:12
      reason:"hava sıcaklıgı"
      date:4
    * product-id: 2426
      amount:12
      reason:"hava sıcaklıgı"
      date:4
    * product-id: 2426
      amount:12
      reason:"hava sıcaklıgı"
      date:4      
ractive=new Ractive do
    el: '#example_container'
    template: '#donutTemplate'
    data:
        kds:''
        products:[9]


ractive.on do
    select : (event,id)->if event.hover then @set 'id',id else @set 'id',null
    get-kds-data:(event,id) -> get-kds-data!

products=
    * id: 2426
      name: "domates"
    * id: 2458
      name: "patates"


ractive.on 'complete', !->
    get-soap!
    ractive.set \products products

convert-kds = (x) ->
    score-keys = <[ score1 score2 score3 score4 score5 ]>
    a=[{supplier-code: ..SupplierCode, score: lists-to-obj score-keys, (split '' ..Score)}  for x.Data.0.Scores]
    b=[{supplier-name: ..supplier-code, scores: [ {id: key ,value: parse-int ..score[key]} for key of ..score] } for a ]
    console.log b
    b

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
            alert "�r�n listesi al�namad�.\n Servise Ula��lam�yor."


# js2ls ile d�zenlenen k�s�m
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
