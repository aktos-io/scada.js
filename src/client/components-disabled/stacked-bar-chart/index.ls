component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    data: ->
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-graph-data:(data-list) ->
            /* this function returns list of data points
                in order to draw a stacked progress bar.

                input data format:

                    input-data =
                        * name: "My data 1"
                          amount: amount1
                        * name: "My data 2"
                          amount: amount2

                data format is as follows:

                    points =
                        * name: "My data 1"
                          amount: amount1
                          start-x: 0
                          center-x: start-x + amount1 / 2
                        * name: "My data 2"
                          amount: amount2
                          start-x: 0 + amount1
                          center-x: start-x + amount2 / 2
                        * name: "My data 3"
                          amount: amount3
                          start-x: 0 + amount1 + amount2
                          center-x: start-x + amount3 / 2
                        ...
            */
            #console.log "data-list: " , data-list
            r = []
            for i in data-list
                data-point = {name: i.name, amount: i.amount}

                # add cumulative starting coordinate to each data point
                data-point.start-x = sum [..amount for r]
                data-point.center-x = data-point.start-x + (data-point.amount / 2)
                #console.log "sum: ", data-point.start-x

                r ++= [data-point]
                #console.log "r: ", r
            return r
