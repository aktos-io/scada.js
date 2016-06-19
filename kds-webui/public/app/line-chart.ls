{maximum-by, last, sort-by, split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/


LineChart = Ractive.extend do
    template: '#linechart'
    init: ->
            
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
                    * x: 1
                      y: 5
                    * x: 15
                      y: 16
                      
            to:
                
                "1 5,15 16"
            */
            
            scaled-points = @scaled-points!
            #console.log "djsdjkcnlkd: ", scaled-points
            x = join ' ' ["#{..x},#{..y}" for points]
            console.log x
            x           
 
my-data = 
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
    
    
 
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        kds-to-points: my-data   
    components:
        linechart: LineChart

