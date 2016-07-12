{maximum-by, last, sort-by, split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

<<<<<<< dd40919a7b966082e27bf5b160d727e66aa4f955

LineChart = Ractive.extend do
    template: '#linechart'
    init: ->
<<<<<<< 5c1446c6fdf461c0255366f9eb66b623e0e288c2
            
        points = @get "points"
        @set "scaledPoints", @scaled-points
        scaled-points = @scaled-points!
        #console.log "test init: ", scaled-points
        
        a = [{x: scaled-points[i].x, data: points[i].x}  for i of points]
        
        #console.log "a is: ", a
        @set "xLabels", a
        

        #height= @get \height
        #y-labels= [height to 0 by -50]
        #console.log y-labels
        b = [{y: scaled-points[i].y, data: points[i].y}  for i of points]
        @set "yLabels", b
        
=======
        points = @get "points"
        @set "scaledPoints", @scaled-points
        scaled-points = @scaled-points!

        #console.log "a is: ", a
        x-labels = [0 to (last scaledPoints).x by 10]
        console.log "x-labels: ", x-labels
        @set "xLabels", x-labels


        height= @get \height
        y-labels = [0 to height by 50]
        console.log "y-labels: ", y-labels
        @set "yLabels", y-labels

>>>>>>> line-chart axis labels are added, not working correctly though
    scaled-points: ->
        points = @get "points"            
        sorted-x = sort-by (.x),points
        max-x = last sorted-x .x
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
        
    data:         
        y-labels: null
        x-labels: null    
        scaled-points: null
 
        convert-to-svg-points: (points) ->
        
            /* converts points for the following format: 
            
                @points = 
=======
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
    template: '#line-chart'
    data:
        convert-to-svg-points: ->
            /* converts points for the following format:

                @points =
>>>>>>> line-chart cleaned up
                    * x: 1
                      y: 5
                    * x: 15
                      y: 16

            to:

                "1 5,15 16"
            */
<<<<<<< dd40919a7b966082e27bf5b160d727e66aa4f955
            
            scaled-points = @scaled-points!
            #console.log "djsdjkcnlkd: ", scaled-points
            x = join ' ' ["#{..x},#{..y}" for points]
            console.log x
<<<<<<< 5c1446c6fdf461c0255366f9eb66b623e0e288c2
            x           
 
my-data = 
=======
            x


# ------------------------------------------------------------ #
                # Edit only Below #
# ------------------------------------------------------------ #

my-data =
>>>>>>> line-chart axis labels are added, not working correctly though
    * x: 1 # date
      y: 1.5 # amount
    * x: 3
      y: 4.5
    * x: 4
      y: 5.5
    * x: 5
      y: 3  
    * x: 8.5 
      y: 10 
    * x: 10
      y: 0.8
    
    
 
=======

            points = @get "points"

            max-x = last points .x
            max-y = maximum-by (.y), points
            #console.log max-y.y
            width = @get \width
            height = @get \height
            console.log height
            scale-factor-x = width / max-x
            scale-factor-y = height / max-y.y
            x = join ' ' ["#{..x * scale-factor-x},#{height - (..y * scale-factor-y)}" for points]
            console.log x
            x


<<<<<<< 5c1446c6fdf461c0255366f9eb66b623e0e288c2



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



>>>>>>> line-chart cleaned up
=======
>>>>>>> line-chart axis labels are added, not working correctly though
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
<<<<<<< dd40919a7b966082e27bf5b160d727e66aa4f955
        kds-to-points: my-data   
=======
        kds-to-points: convert-kds-to-linechartpoints 2426
>>>>>>> line-chart cleaned up
    components:
        linechart: LineChart

