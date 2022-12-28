require! 'rickshaw':Rickshaw
require! 'prelude-ls': {empty, first, last, is-it-NaN}
require! 'aea': {unix-to-readable, sleep}
require! 'aea/formatting': {displayFormat, parse-format}

Ractive.components['time-seriesASYNC'] = Ractive.extend do
    template: '
        <div class="time-series chart-container {{class}}"
            style="
                {{#if height}}height: {{height}};{{/if}}
                {{#if width}}width: {{width}};{{/if}}
                padding-left: {{@.get("y-width")}}px;
                ">
            <div class="chart"></div>
            <div class="slider"></div>
            <div class="y-axis" style="width: {{@.get("y-width") + 30}}px; position: absolute; left: -9px; top: 0; bottom: 0"></div>
        </div>
        '

    isolated: yes
    onrender: ->>
        y-format = @get \y-format
        unless y-format
            console.error "time-series error: y-format attribute is required!"
            return

        get-holder = ~> @find ".chart"

        graph = new Rickshaw.Graph do
            element: get-holder!
            interpolation: \step-after
            stack: false
            series:
                * color: 'steelblue',
                  data: [{x: 0, y: 0, +tmp}]
                  name: @get \name
                ...
            max: @get \y-max
            min: @get \y-min

        graph.render();

        #ticksTreatment = \glow

        x-axis = new Rickshaw.Graph.Axis.Time do
            graph: graph
            # x-tick labels are removed by the CSS file

        x-axis.render!

        y-axis = new Rickshaw.Graph.Axis.Y do
            graph: graph
            orientation: 'left',
            tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
            element: @find '.y-axis'
            pixelsPerTick: 75

        y-axis.render!

        hover-detail = new Rickshaw.Graph.HoverDetail do
            graph: graph
            x-formatter: (x) -> unix-to-readable x
            y-formatter: (x) -> displayFormat y-format, x .full-text

        slider-element = @find \.slider
        slider = null 
        make-slider = ->
            return if slider?
            if graph.series.0.data.length > 0
                slider := new Rickshaw.Graph.RangeSlider.Preview do
                    graph: graph
                    element: slider-element
   
        make-slider!
        graph.update! 

        # resize graph on window resize
        $(window).resize -> 
            dimensions = get-holder!.getBoundingClientRect()
            try 
                graph.configure {dimensions?.width, dimensions?.height}
                graph.render!
        
        h = @observe \data, (_new) ->
            if (typeof! _new is \Array) and _new.length > 0
                # remove the temporary points (inserted below for the live data display)
                i = _new.length
                while i--
                    if _new[i].tmp?
                        _new.splice(i, 1);
                        break

                size = @get('size')
                if +size > 0 
                    while _new.length > size
                        _new.shift!

                graph.series.0.data = _new
                if @get('live')
                    graph.series.0.data.push {y: _new[*-1].y, x: _new[*-1].x, +tmp}
                graph.update!

        # update the timestamp of the temporary point at the end of data for live data animation
        while @get('live')
            h.silence!
            data = graph.series.0.data
            if data[*-1]?.tmp
                if Date.now! > data[*-1].x
                    data[*-1].x = Date.now!
                    graph.update!

            h.resume!
            await sleep 1000ms 

    data: ->
        name: 'Value'
        data: []
        'y-format': ''
        'y-max': undefined
        'y-min': 0
        'y-width': 20
        live: false
        size: 0

/*


// set up our data series with 150 random data points

var seriesData = [ [], [], [], [], [], [], [], [], [] ];
var random = new Rickshaw.Fixtures.RandomData(150);

for (var i = 0; i < 150; i++) {
    random.addData(seriesData);
}

var palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } );

// instantiate our graph!

var graph = new Rickshaw.Graph( {
    element: document.getElementById("chart"),
    width: 900,
    height: 500,
    renderer: 'area',
    stroke: true,
    preserve: true,
    series: [
        {
            color: palette.color(),
            data: seriesData[0],
            name: 'Moscow'
        }, {
            color: palette.color(),
            data: seriesData[1],
            name: 'Shanghai'
        }, {
            color: palette.color(),
            data: seriesData[2],
            name: 'Amsterdam'
        }, {
            color: palette.color(),
            data: seriesData[3],
            name: 'Paris'
        }, {
            color: palette.color(),
            data: seriesData[4],
            name: 'Tokyo'
        }, {
            color: palette.color(),
            data: seriesData[5],
            name: 'London'
        }, {
            color: palette.color(),
            data: seriesData[6],
            name: 'New York'
        }
    ]
} );

graph.render();

var preview = new Rickshaw.Graph.RangeSlider( {
    graph: graph,
    element: document.getElementById('preview'),
} );

var hoverDetail = new Rickshaw.Graph.HoverDetail( {
    graph: graph,
    xFormatter: function(x) {
        return new Date(x * 1000).toString();
    }
} );

var annotator = new Rickshaw.Graph.Annotate( {
    graph: graph,
    element: document.getElementById('timeline')
} );

var legend = new Rickshaw.Graph.Legend( {
    graph: graph,
    element: document.getElementById('legend')

} );

var shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
    graph: graph,
    legend: legend
} );

var order = new Rickshaw.Graph.Behavior.Series.Order( {
    graph: graph,
    legend: legend
} );

var highlighter = new Rickshaw.Graph.Behavior.Series.Highlight( {
    graph: graph,
    legend: legend
} );

var smoother = new Rickshaw.Graph.Smoother( {
    graph: graph,
    element: document.querySelector('#smoother')
} );

var ticksTreatment = 'glow';

var xAxis = new Rickshaw.Graph.Axis.Time( {
    graph: graph,
    ticksTreatment: ticksTreatment,
    timeFixture: new Rickshaw.Fixtures.Time.Local()
} );

xAxis.render();

var yAxis = new Rickshaw.Graph.Axis.Y( {
    graph: graph,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
    ticksTreatment: ticksTreatment
} );

yAxis.render();


var controls = new RenderControls( {
    element: document.querySelector('form'),
    graph: graph
} );

// add some data every so often

var messages = [
    "Changed home page welcome message",
    "Minified JS and CSS",
    "Changed button color from blue to green",
    "Refactored SQL query to use indexed columns",
    "Added additional logging for debugging",
    "Fixed typo",
    "Rewrite conditional logic for clarity",
    "Added documentation for new methods"
];

setInterval( function() {
    random.removeData(seriesData);
    random.addData(seriesData);
    graph.update();

}, 3000 );

function addAnnotation(force) {
    if (messages.length > 0 && (force || Math.random() >= 0.95)) {
        annotator.add(seriesData[2][seriesData[2].length-1].x, messages.shift());
        annotator.update();
    }
}

addAnnotation(true);
setTimeout( function() { setInterval( addAnnotation, 6000 ) }, 6000 );

var previewXAxis = new Rickshaw.Graph.Axis.Time({
    graph: preview.previews[0],
    timeFixture: new Rickshaw.Fixtures.Time.Local(),
    ticksTreatment: ticksTreatment
});

previewXAxis.render();

*/
