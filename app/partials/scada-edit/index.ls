require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

require! {
  '../../modules/prelude': {
    empty
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
          parent-coord = $ this .parents \.scada-drawing-area .position!

          x = $ this .attr \data-x or 0
          y = $ this .attr \data-y or 0

          w = $ this .css \width
          h = $ this .css \height

          #console.log "widget found: wid: #wid, x: #x, y: #y, width: #w, height: #h, top: #{parent-coord.top}, left: #{parent-coord.left}", $ this

          layout := layout + "  * wid: #wid" + \\n
          layout := layout + "    x: #x" + \\n
          layout := layout + "    y: #y" + \\n
          layout := layout + "    w: #w" + \\n
          layout := layout + "    h: #h" + \\n

      console.log "Layout: " + \\n + layout

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
