require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

require! {
  '../../modules/prelude': {
    flatten,
    initial,
    drop,
    join,
    concat,
    tail,
    head,
    map,
    zip,
    split,
    union,
    last
  }
}


RactivePartial! .register ->
  $ \.zoom-graph .each ->
    actor = IoActor $ this

    elem = actor.node.find \.zoom-graph__graph

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

RactivePartial! .register ->
  $ \.overview-graph .each ->
    actor = IoActor $ this

    elem = actor.node.find \.overview-graph__graph

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    #console.log "this is graph widget: ", elem, actor.actor-name

    /*
    graph-data = ->
      return do
        * label: 'test'
          data: get-graph-data!
          color: 'white'
        * label: 'test2'
          data: get-graph-data!
          color: 'red'

    */
    ``
    $(function() {
      function getData(x1, x2) {

    		var d = [];
    		for (var i = 0; i <= 100; ++i) {
    			var x = x1 + i * (x2 - x1) / 100;
    			d.push([x, Math.sin(x * Math.sin(x))]);
    		}

    		return [
    			{ label: "sin(x sin(x))", data: d }
    		];
    	}

    	var options = {
    		legend: {
    			show: false
    		},
    		series: {
    			lines: {
    				show: true
    			},
    			points: {
    				show: true
    			}
    		},
    		yaxis: {
    			ticks: 10
    		},
    		selection: {
    			mode: "xy"
    		}
    	};

    	var startData = getData(0, 3 * Math.PI);

    	var plot = $.plot(".zoom-graph", startData, options);

      // Create the overview plot

      var overview = $.plot(".overview-graph", startData, {
    		legend: {
    			show: false
    		},
    		series: {
    			lines: {
    				show: true,
    				lineWidth: 1
    			},
    			shadowSize: 0
    		},
    		xaxis: {
    			ticks: 4
    		},
    		yaxis: {
    			ticks: 3,
    			min: -2,
    			max: 2
    		},
    		grid: {
    			color: "#999"
    		},
    		selection: {
    			mode: "xy"
    		}
      });

    	// now connect the two

    	$(".zoom-graph").bind("plotselected", function (event, ranges) {

    		// clamp the zooming to prevent eternal zoom

    		if (ranges.xaxis.to - ranges.xaxis.from < 0.00001) {
    			ranges.xaxis.to = ranges.xaxis.from + 0.00001;
    		}

    		if (ranges.yaxis.to - ranges.yaxis.from < 0.00001) {
    			ranges.yaxis.to = ranges.yaxis.from + 0.00001;
    		}

    		// do the zooming

    		plot = $.plot(".zoom-graph", getData(ranges.xaxis.from, ranges.xaxis.to),
    			$.extend(true, {}, options, {
    				xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
    				yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
    			})
    		);

    		// don't fire event on the overview to prevent eternal loop

    		overview.setSelection(ranges, true);
    	});

      $(".overview-graph").bind("plotselected", function (event, ranges) {
    		plot.setSelection(ranges);
    	});
    });

    ``

    actor.add-callback (msg) ->
      console.log "zoom-graph got new value: #{msg.val}"
      console.log "overview-graph got new value: #{msg.val}"
      #refresh!


      /*
          data = []
          total-points = 300

          y-max = 100
          y-min = 0

          push-random-data = ->
            if data.length > 0
              data := tail data

            while data.length < total-points

              prev = if data.length > 0 then last data else y-max / 2

              y = prev + Math.random! * 10  - 5
              y = y-min if y < y-min
              y = y-max if y > y-max

              data.push y

          get-graph-data = ->
            return [zip [0 to total-points] data]

          #console.log "random data: ", get-random-data!

          push-graph-data = (new-point) ->
            totalPoints = 300
            if data.length > 0 then
              data := tail data
            while data.length < total-points
              data.push new-point


          update-interval = 30

          push-random-data!
          plot = $.plot ('#' + actor.actor-id), get-graph-data!, do
            series:
              shadow-size: 0
            yaxis:
              min: y-min
              max: y-max
            xaxis:
              show: false


          refresh = ->
            plot.set-data get-graph-data!
            plot.draw!


          update = ->
            #push-random-data!
            push-graph-data last data
            plot.set-data get-graph-data!
            plot.resize!
            plot.setup-grid!
            plot.draw!
            set-timeout update, update-interval

          update!

      */
