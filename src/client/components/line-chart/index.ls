require! 'c3'

Ractive.components['line-chart'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        /*
        chart = c3.generate do
            bind-to: '#chart'
            data:
                columns:
                    ['data1', 30, 200, 100, 400, 150, 250]
                    ['data2', 50, 20, 10, 40, 15, 25]
        */

        @observe \data1, (_new) ->
            x-axis = ['x']
            y-axis = ['level']
            for point in _new
                continue unless point.key
                x-axis.push point.key
                y-axis.push point.value

            chart = c3.generate do
                bind-to: '#chart'
                data:
                    x: 'x'
                    columns: [x-axis, y-axis]
