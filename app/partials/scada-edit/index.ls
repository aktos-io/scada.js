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
    empty,
    initial,
    drop,
    join,
    concat,
    tail,
    head,
    map,
    zip,
    split,
    last,
  }
}



RactivePartial! .register ->
  $ '.scada-generate-layout' .each !->
    actor = IoActor $ this

    input = actor.node

    input.on 'click', ->
      console.log "GENERATE LAYOUT!"

      layout = "widget-positions = \n"
      $ '.draggable, .draggable-locked' .each ->
        wid = $ this .attr \data-wid

        if wid?
          # widget found, get position information
          parent-coord = $ this .closest \.scada-container .position!

          if not parent-coord?
            console.log "why? wid: ", wid
          else
            x = ($ this .attr \data-x |> parse-float)
            y = ($ this .attr \data-y |> parse-float)

            w = $ this .css \width
            h = $ this .css \height

            if x < 0 or y < 0
              console.log "something is wrong. check how you calculated the widget coordinates of wid: ", wid, "parent: ", parent-coord

            # do not accept negative values
            x = x >? 0
            y = y >? 0

            #console.log "widget found: wid: #wid, x: #x, y: #y, width: #w, height: #h, top: #{parent-coord.top}, left: #{parent-coord.left}", $ this

            layout := layout + "  * wid: #wid" + \\n
            layout := layout + "    x: #x" + \\n
            layout := layout + "    y: #y" + \\n
            layout := layout + "    w: #w" + \\n
            layout := layout + "    h: #h" + \\n

      #console.log "Layout: " + \\n + layout

      $ ('#layout-output-area-' + actor.actor-id) .html layout



RactivePartial! .register-for-dynamic-pos (wpos) ->
  $ '.draggable' .each ->
    actor = $ this .data \actor

    if actor?
      wid = actor.get-ractive-var \wid
      widget = actor.node
      if wid?
        db = [p for p in wpos when p.wid == wid]
        if not empty db
          [x, y] = [db.0.x, db.0.y]
          #console.log "dynamic-pos: this widget's id: #wid position: ", x, y

          pos = 'translate(' + x + 'px, ' + y + 'px)'
          widget.css \webkitTransform, pos
          widget.css \transform, pos

          # set data-* attributes
          widget.attr \data-x, x
          widget.attr \data-y, y

          [width, height] = [db.0.w, db.0.h]
          widget.css \width, width
          widget.css \height, height


        else
          console.log "status-led: no matching widget position found for wid: #wid", db

        # set widget id anyway
        widget.attr \data-wid, wid

      else
        console.log "status-led: no wid found for this widget...", wid

    else
      console.log "ERROR: A DRAGGABLE HAS NO ACTOR!"

RactivePartial!register ->
  drag-move-listener = (event) ->
    target = event.target
    x = ((parse-float target.get-attribute \data-x) or 0) + event.dx
    y = ((parse-float target.get-attribute \data-y) or 0) + event.dy

    a = 'translate(' + x + 'px, ' + y + 'px)'
    target.style.webkit-transform = a
    target.style.transform = a

    target.set-attribute \data-x, x
    target.set-attribute \data-y, y

  interact \.draggable .draggable do
    snap:
      targets:
        * interact.createSnapGrid({ x: 10, y: 10 })
        ...
      range: Infinity,
      relativePoints:
        * { x: 0, y: 0 }
        ...
    inertia: true
    restrict:
      end-only: true
      element-rect: {top: 0, left: 0, bottom: 1, right: 1}

    onmove: drag-move-listener
    onend: (event) ->
      console.log "moved: x: #{event.dx} y: #{event.dy}"

  .resizable edges: { left: no, right: yes, bottom: yes, top: no }
  .on \resizemove, (event) ->
    target = event.target
    x = ((parse-float target.get-attribute \data-x) or 0) + event.dx
    y = ((parse-float target.get-attribute \data-y) or 0) + event.dy

    # update the element's style
    target.style.width  = event.rect.width + 'px'
    target.style.height = event.rect.height + 'px'



    # translate when resizing from top or left edges
    x += event.deltaRect.left
    y += event.deltaRect.top

    console.log "event.delta-rect: ", event.deltaRect.left, event.delta-rect.right

    a = "translate(#{x}px, #{y}px)"
    target.style.webkit-transform = a
    target.style.transform = a

    #target.set-attribute \data-x, x
    #target.set-attribute \data-y, y

    console.log "resized: ", event.rect.width + '×' + event.rect.height


RactivePartial! .register-for-post-ready ->
  # lock scada
  lock = SwitchActor \lock-scada

  lock.add-callback (msg) ->
    if msg.val is true
      $ \.draggable .each ->
        $ this .remove-class \draggable
        $ this .add-class \draggable-locked
        $ this .remove-class \read-only
    else
      $ \.draggable-locked .each ->
        $ this .remove-class \draggable-locked
        $ this .add-class \draggable
        $ this .add-class \read-only

  # lock scada externally
  SwitchActor \lock-scada .gui-event on
