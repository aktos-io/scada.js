{split, take, join, lists-to-obj} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/


DonutChart=Ractive.extend do
    template: '#donutchart'
    init:(options)->
        self=@
        delay=@get 'delay'
        setTimeout (->
          self.animate 'c', Math.PI * 2, {
            duration: 800
            easing: 'easeOut'
          }
          return ), delay
        return
    data:{
        c:0
        colors:{score1: '#ffc829',score2: '#729d34',score3: '#ff5500',score4:'#ccefff',score5:'#c00999'}
        getSegments:(data)->
            total=data.reduce(((previous,current)-> previous+current.value), 0)
            data = data.slice!.sort ((a, b) -> b.value - a.value)
            start=0
            segments=data.map((datum)->
                size = datum.value / total
                end = start + size
                segment={id:{datum.id,datum.value}, start: start,end: end}
                start:=end
                segment)
            segments
        getSegmentPoints:(segment, innerRadius, outerRadius, c)->
            points=[]
            start = segment.start * c
            end = segment.end * c
            getPoint=(angle,radius)->( ( radius * Math.sin( angle ) ).toFixed( 2 ) + ',' + ( radius * -Math.cos( angle ) ).toFixed( 2 ) )
            for angle from start to end by 0.05
                points[ points.length ] = getPoint angle, outerRadius
            points[ points.length ] = getPoint end, outerRadius
            for angle from end to start by -0.05
                points[ points.length ] = getPoint angle, innerRadius
            points[ points.length ] = getPoint start, innerRadius
            return points.join ' '
    }

kds-data= [
    supplier-name: \hilmi
    scores:[
        *id:'score1'
         value:9
        *id:'score2'
         value:2
        *id:'score3'
         value:2
        *id:'score4'
         value:2
        *id:'score5'
         value:2
         ],
    \fahriye
    scores:[
        *id:'score1'
         value:1
        *id:'score2'
         value:3
        *id:'score3'
         value:5
        *id:'score4'
         value:7
        *id:'score5'
         value:4
         ]
    ]

ractive=new Ractive do
    el: '#example_container'
    template: '#donutTemplate'
    data:
        kds:kds-data
        products:[9]
    components:
        donutchart: DonutChart

ractive.on do
    select : (event,id)->if event.hover then @set 'id',id else @set 'id',null
    get-kds-data:(event,id) -> get-kds-data!

products=
    * id:19
      name:"domates"
    * id:6
      name:"patates"


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
    ractive.set \kds ''
    $.get "http://78.189.167.200/DemeterKds/api/rfm/ScoresVersion?rawMaterialCode=#{ractive.get 'kdsProductId'}&VersionNumber=635973759505058264", (text) ->
        ractive.set \kds, convert-kds text


getSoap = ->
    $.soap do
        url :"http://78.189.167.200:2222/Servis/DemeterWS/RawMaterialOrderService.svc"
        SOAPAction : "http://tempuri.org/IRawMaterialOrderService/GetRawMaterialList"
        method : "GetRawMaterialList"
        data : {}
        appendMethodToURL : no
        namespaceURL : "http://tempuri.org/"
        success:(xml)->
            xml = xml.to-string!
            xml-new = xml.replace /a:/g, ''
            my-obj = []

            $ xml-new
                .find \GetRawMaterialListResponse
                .find \GetRawMaterialListResult
                .find \RawMaterial
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
            alert "Ürün listesi alınamadı.\n Servise Ulaşılamıyor."


# js2ls ile düzenlenen kısım
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
