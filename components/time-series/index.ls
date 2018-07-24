require! 'rickshaw':Rickshaw
require! 'prelude-ls': {empty, first, last, is-it-NaN}
require! 'aea': {unix-to-readable}
require! 'aea/formatting': {displayFormat, parse-format}

Ractive.components['time-series'] = Ractive.extend do
    template: '
        <div class="time-series chart-container {{class}}"
            style="
                {{#if height}}height: {{height}};{{/if}}
                {{#if width}}width: {{width}};{{/if}}
                ">
            <div class="chart"></div>
            <div class="y-axis"></div>
            <div class="slider"></div>
        </div>
        '

    isolated: yes
    onrender: ->
        y-format = @get \y-format
        unless y-format
            console.error "time-series error: y-format attribute is required!"
            return

        graph = new Rickshaw.Graph do
            element: @find ".chart"
            interpolation: \step-after
            series:
                * color: 'steelblue',
                  data: []
                  name: @get \name
                ...

        graph.render();

        #ticksTreatment = \glow

        x-axis = new Rickshaw.Graph.Axis.Time do
            graph: graph

        x-axis.render!

        y-axis = new Rickshaw.Graph.Axis.Y do
            graph: graph
            orientation: 'left',
            tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
            element: @find '.y-axis'

        y-axis.render!

        hover-detail = new Rickshaw.Graph.HoverDetail do
            graph: graph
            x-formatter: (x) -> unix-to-readable x
            y-formatter: (x) -> displayFormat y-format, x .full-text

        slider-element = @find \.slider
        slider-made = no
        make-slider = ->
            return if slider-made
            if graph.series.0.data.length > 0
                slider = new Rickshaw.Graph.RangeSlider.Preview do
                    graph: graph
                    element: slider-element
                slider-made := yes

        append-new = (_new) ->
            if typeof! _new isnt \Array
                _new = [{key: (Date.now!), value: _new}]

            serie = graph.series.0.data
            if last serie
                if (first _new .key) < that.x
                    console.error "time-series error: can not add points in the middle."
                    return

            for point in _new
                serie.push {x: point.key, y: point.value}

        @observe \data, (_new) ->
            if typeof! _new is \Array
                x = graph
                graph.series.0.data = [{x: ..key, y: ..value} for _new]
                make-slider!
                graph.update!

        @observe \current, (curr) ->
            if @get \live
                #console.log "appending live data: ", curr
                curr = parse-float curr
                unless is-it-NaN curr
                    append-new curr
                    make-slider!
                    graph.update!

    data: ->
        data: []


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
