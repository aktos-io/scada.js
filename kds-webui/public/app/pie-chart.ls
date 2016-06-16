{split, take, join, lists-to-obj} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

PieChart = Ractive.extend do
    template: '#pie-chart'
    oninit: ->
        col-list = @get \names |> split ','
        @set \columnList, col-list

    init:(options)->
        @animate 'c' , Math.PI*2
    data:
        names: void
        column-list: void
        c: 0
        colors:{score1: '#08088A',score2: '#151515',score3: '#585858'}

        getSegments:(data)->
            console.log data
            total=data.reduce(((previous,current)-> previous+current.value), 0)
            data = data.slice!.sort ((a, b) -> b.value - a.value)
            start=0
            segments=data.map((datum)->
                size = datum.value / total
                end = start + size
                segment={id:datum,value:datum.value,start: start,end: end}
                start:=end
                segment)
            console.log "segments: ", segments
            segments

        getSegmentPoints:(segment, innerRadius, outerRadius)->
            points=[]
            start = segment.start * @get \c
            end = segment.end * @get \c
            getPoint=(angle,radius)->( ( radius * Math.sin( angle ) ).toFixed( 2 ) + ',' + ( radius * -Math.cos( angle ) ).toFixed( 2 ) )
            for angle from start to end by 0.05
                points[ points.length ] = getPoint angle, outerRadius
            points[ points.length ] = getPoint end, outerRadius
            for angle from end to start by -0.05
                points[ points.length ] = getPoint angle, innerRadius
            points[ points.length ] = getPoint start, innerRadius
            #console.log "test:" , points.join ' '
            return points.join ' '

kds-data=
    scores:
        *id:'score1'
         value:1
        *id:'score2'
         value:22
        *id:'score3'
         value: 55

ractive=new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        kds:kds-data
        my-data: [3,5,7]
        x: kds-data.scores
    components:
        piechart: PieChart
