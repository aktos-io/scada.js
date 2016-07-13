
component-name = "flot-chart"
Ractive.components[component-name] = Ractive.extend do
    oninit: ->

        data1 = @get \data1
        data2 = @get \data2

        $ document .ready ->

            $('#flot-dashboard-mahmut').length and $.plot($('#flot-dashboard-mahmut'), [
                data1, data2
            ],
                    {
                        series: {
                            lines: {
                                show: true,
                                fill: true
                            },
                            splines: {
                                show: true,
                                tension: 0.4,
                                lineWidth: 1,
                                fill: 0.4
                            },
                            points: {
                                radius: 5,
                                show: true
                            },
                            shadowSize: 2
                        },
                        grid: {
                            hoverable: true,
                            clickable: true,
                            tickColor: '#d5d5d5',
                            borderWidth: 1,
                            color: '#d5d5d5'
                        },
                        colors: ["\#1ab394", "\#1C84C6"],
                        xaxis:{
                        },
                        yaxis: {
                            ticks: 4
                        },
                        tooltip: true
                    }
            )

    template: "\##{component-name}"
    data: {}
