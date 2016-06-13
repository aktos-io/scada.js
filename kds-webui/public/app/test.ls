{split, take, join, lists-to-obj} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

after = (ms, f) -> set-timeout f, ms
sleep = after

DonutChart=Ractive.extend do
    template: '#donutchart'
    init:(options)->
        @animate 'mahmut' , Math.PI*2
    data:{
        mahmut: 0
        colors:{score1: '#08088A',score2: '#151515',score3: '#585858'}
        getSegments:(data)->
            total=data.reduce(((previous,current)-> previous+current.value), 0)
            data = data.slice!.sort ((a, b) -> b.value - a.value)
            start=0
            segments=data.map((datum)->
                size = datum.value / total
                end = start + size
                segment={id:datum,value:datum.value,start: start,end: end}
                start:=end
                segment)
            segments
        getSegmentPoints:(segment, innerRadius, outerRadius)->
            points=[]
            start = segment.start * @get \mahmut
            end = segment.end * @get \mahmut
            getPoint=(angle,radius)->( ( radius * Math.sin( angle ) ).toFixed( 2 ) + ',' + ( radius * -Math.cos( angle ) ).toFixed( 2 ) )
            for angle from start to end by 0.05
                points[ points.length ] = getPoint angle, outerRadius
            points[ points.length ] = getPoint end, outerRadius
            for angle from end to start by -0.05
                points[ points.length ] = getPoint angle, innerRadius
            points[ points.length ] = getPoint start, innerRadius
            console.log "test:" , points.join ' '
            return points.join ' '
    }

kds-data= [
    supplier-name: \test
    scores:[
        *id:'score1'
         value:9
        *id:'score2'
         value:2
        *id:'score3'
         value:3
         ],
     \test1
     scores:[
         *id:'score1'
          value:9
         *id:'score2'
          value:2
         *id:'score3'
          value:3
          ],
      \test2
      scores:[
          *id:'score1'
           value:9
          *id:'score2'
           value:2
          *id:'score3'
           value:3
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

convert-kds = (x) ->
    score-keys = <[ score1 score2 score3 ]>
    a=[{supplier-code: ..SupplierCode, score: lists-to-obj score-keys, (split '' ..Score)}  for x.Data.0.Scores]


get-kds-data = ->
    console.log "getting kds data..."
    ractive.set \kds ''
    $.get "http://192.168.9.111/DemeterKds/api/rfm/ScoresVersion?rawMaterialCode=#{ractive.get 'kdsProductId'}&VersionNumber=635973759505058264", (text) ->
        ractive.set \kds, convert-kds text
