{maximum-by, last, sort-by, split, take, join, lists-to-obj, sum} = require 'prelude-ls'
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
      date:22
    * product-id: 2426
      amount:40
      reason:"sebep dd"
      date:7
    * product-id: 2426
      amount:14
      reason:"sebep aa"
      date:6
    * product-id: 2426
      amount:18
      reason:"sebep bb"
      date:5
    * product-id: 2426
      amount:11
      reason:"sebep cc"
      date:11
    * product-id: 2426
      amount:0
      reason:"sebep dd"
      date:5
    * product-id: 2458
      amount:100
      reason:"ie bozuk"
      date:15
    * product-id: 2458
      amount:15
      reason:"ui bozuk"
      date:6
    * product-id: 2458
      amount:1
      reason:"ui bozuk"
      date:2      

LineChart = Ractive.extend do
    template: '#linechart'
    oninit: ->
            width = @get \width
            x-labels=[0 to width by 50]
            @set "xLabels", x-labels 
            
            height= @get \height
            y-labels= [(height+50) to 0 by -50]
            #console.log y-labels
            @set "yLabels", y-labels
    data:     
        y-labals: null
        x-labels: null        
        scaled-points: ->
            points = @get "points"
            
            max-x = last points .x
            max-y = maximum-by (.y), points
            #console.log max-y.y  
            width = @get \width
            height = @get \height
            #console.log height
            scale-factor-x = width / max-x
            scale-factor-y = height / max-y.y
            a = [{x: ..x * scale-factor-x, y: height - (..y * scale-factor-y)} for points]
            #console.log "scaled points are :", a
            a
        convert-to-svg-points: (points) ->
            /* converts points for the following format: 
            
                @points = 
                    * x: 1
                      y: 5
                    * x: 15
                      y: 16
                      
            to:
                
                "1 5,15 16"
            */
            
            x = join ' ' ["#{..x},#{..y}" for points]
            console.log x
            x
            
            
            
            
                    
convert-kds-to-linechartpoints = (selected-id)-> 
    /* converts kds to line chart points 
        kds=
            * product-id: 2458
              amount:30
              reason:"ie bozuk"
              date:15
            * product-id: 2458
              amount:10
              reason:"ui bozuk"
              date:20
        to:
            points = 
                    * x: 15 # date
                      y: 30 # amount
                    * x: 20
                      y: 10
    */       
    console.log "selected-list: "
    selected-list-temp = [.. for kds-data when ..product-id is (selected-id |> parse-int)]
    selected-list = sort-by (.date),selected-list-temp
    
    console.log selected-list
    #[x as date, y as amount in.. for selected-list] 
    startX=selected-list[0].date;
    points=[{x: (..date)-startX, y: ..amount} for selected-list]

    #p=[{x: ..date-startX}for selected-list]
    console.log points
    points
 

 
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        kds-to-points: convert-kds-to-linechartpoints 2426     
    components:
        linechart: LineChart

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
