require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
    SwitchActor,
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

    console.log "zoom-graph pin-name: ", actor.pin-name

    x-min = SwitchActor (actor.pin-name + "-x-min")
    x-max = SwitchActor (actor.pin-name + "-x-max")
    y-min = SwitchActor (actor.pin-name + "-y-min")
    y-max = SwitchActor (actor.pin-name + "-y-max")

    x-min.add-callback (msg) ->
      console.log "x-min: msg: ", msg
      actor.node.css \background-color, "rgb(#{parse-int msg.val}, 50, 50)"

    x-max.add-callback (msg) ->
      console.log "x-max: msg: ", msg
      actor.node.css \background-color, "rgb(#{parse-int msg.val}, 50, 50)"

    y-min.add-callback (msg) ->
      console.log "y-min: msg: ", msg
      actor.node.css \background-color, "rgb(#{parse-int msg.val}, 50, 50)"

    y-max.add-callback (msg) ->
      console.log "y-max: msg: ", msg
      actor.node.css \background-color, "rgb(#{parse-int msg.val}, 50, 50)"



    elem = actor.node.find \.zoom-graph__graph

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

    	});

      $(".overview-graph").bind("plotselected", function (event, ranges) {
    		plot.setSelection(ranges);
    	});
    });

    ``

    $ \.zoom-graph .on \dblclick, (event) !->
      ``
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
      ``


    actor.add-callback (msg) ->
      console.log "msg: " msg
