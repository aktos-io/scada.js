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
    getData = (x1, x2) ->
      d = []
      i = 0
      while i <= 100
        x = x1 + i * (x2 - x1) / 100
        d.push [x, Math.sin x * Math.sin x]
        ++i
      [{
        label: 'sin(x sin(x))'
        data: d
      }]


    options = {
      legend: {show: false}
      series: {
        lines: {show: true}
        points: {show: true}
      }
      yaxis: {ticks: 10}
      selection: {mode: 'xy'}
    }
    x-min.add-callback (msg) ->
      console.log "x-min: msg: ", msg
      startData = getData 0,msg.val
      plot = $.plot '.zoom-graph', startData, options

    x-max.add-callback (msg) ->
      console.log "x-max: msg: ", msg
      startData = getData 0,msg.val
      plot = $.plot '.zoom-graph', startData, options

    y-min.add-callback (msg) ->
      console.log "y-min: msg: ", msg
      startData = getData 0,msg.val
      plot = $.plot '.zoom-graph', startData, options

    y-max.add-callback (msg) ->
      console.log "y-max: msg: ", msg
      startData = getData 0,msg.val
      plot = $.plot '.zoom-graph', startData, options


    $ (->

      options = {
        legend: {show: false}
        series: {
          lines: {show: true}
          points: {show: true}
        }
        yaxis: {ticks: 10}
        selection: {mode: 'xy'}
      }
      startData = getData 0, 3 * Math.PI
      plot = $.plot '.zoom-graph', startData, options
      ($ '.zoom-graph').bind 'plotselected', (event, ranges) ->
        ranges.xaxis.to = ranges.xaxis.from + 0.00001 if ranges.xaxis.to - ranges.xaxis.from < 0.00001
        if ranges.yaxis.to - ranges.yaxis.from < 0.00001 then ranges.yaxis.to = ranges.yaxis.from + 0.00001
        plot := $.plot '.zoom-graph', (getData ranges.xaxis.from, ranges.xaxis.to), $.extend true, {}, options, {
          xaxis: {
            min: ranges.xaxis.from
            max: ranges.xaxis.to
          }
          yaxis: {
            min: ranges.yaxis.from
            max: ranges.yaxis.to
          }
        }
      ($ '.overview-graph').bind 'plotselected', (event, ranges) -> plot.setSelection ranges)

    $ \.zoom-graph .on \dblclick, (event) !->
      options = {
        legend: {show: false}
        series: {
          lines: {show: true}
          points: {show: true}
        }
        yaxis: {ticks: 10}
        selection: {mode: 'xy'}
      }

      startData = getData 0,5

      plot = $.plot '.zoom-graph', startData, options



    actor.add-callback (msg) ->
      console.log "msg: " msg
