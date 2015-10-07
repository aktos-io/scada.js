
require! {
  '../modules/prelude': {
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
    last,
  }
}


require! {
  '../modules/aktos-dcs': {
    ProxyActor,
    RactivePartial,
    SwitchActor,
    RactiveApp,
  }
}

# get scada layouts
{widget-positions} = require './scada-layout'

# include widgets' initialize codes
require '../partials/ractive-partials'

# Set Ractive.DEBUG to false when minified:
Ractive.DEBUG = /unminified/.test !-> /*unminified*/

app = new Ractive do
  el: 'container'
  template: '#app'

RactiveApp!set app

# Create the actor which will connect to the server
proxy-actor = ProxyActor!

app.on 'complete', !->
  # create actors and init widgets
  RactivePartial! .init!

  $ document .ready ->
    console.log "document is ready..."
    RactivePartial! .init-for-document-ready!
    RactivePartial! .init-for-dynamic-pos widget-positions
    set-timeout (->
      RactivePartial! .init-for-post-ready!
      ), 1000

  # Update all I/O on init
  proxy-actor.update-connection-status!

  console.log "ractive app completed..."

  /*
  console.log "Testing sending data to table from app.ls"
  test = SwitchActor 'test-actor'
  test.send IoMessage:
    pin_name: \test-table
    table_data:
      * <[ bir iki üç dört beş ]>
      * <[ 1bir 1iki 1üç 1dört 1beş ]>
      * <[ 2bir 2iki 2üç 2dört 2beş ]>
  */

  /*

  console.log "Performance testing via gauge-slider pin"

  test2 = SwitchActor \gauge-slider

  i = 0
  j = +1
  up = ->
    test2.gui-event i
    #app.set \abc, i
    if i >= 100
      j := -1
    if i <= 0
      j := +1
    i := i + j
    set-timeout up, 1000

  set-timeout up, 2000

  test3 = SwitchActor \gauge-slider2

  k = 0
  l = +1
  up2 = ->
    test3.gui-event k
    #app.set \abc, k
    if k >= 100
      l := -1
    if k <= 0
      l := +1
    k := k + l
    set-timeout up2, 1000

  set-timeout up2, 2000

  */

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
      restriction: \.scada-drawing-area
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


RactivePartial! .register-for-dynamic-pos ->
  # lock scada
  lock = SwitchActor \lock-scada

  lock.add-callback (msg) ->
    if msg.val is true
      $ \.draggable .each ->
        $ this .remove-class \draggable
        $ this .add-class \draggable-locked
    else
      $ \.draggable-locked .each ->
        $ this .remove-class \draggable-locked
        $ this .add-class \draggable

  # lock scada externally
  SwitchActor \lock-scada .gui-event on

# Handle page navigation
# -----------------------
handle-navigation = ->
  page = window.location.hash.replace /^#/, '' .split '/'

  console.log "hash changed: #{page}"

  # try to scroll to anchor, immediately or after page change
  scroll-to-anchor = (anchor) ->
    if anchor
      console.log "navigate to anchor: #{anchor} and last: #{last anchor}"
      if (last anchor) is '!'
        # this is popup
        console.log "this is popup: #{last anchor}"
        $ ('#' + initial anchor) .popup \open
      else
        try
          target = $('#' + anchor).offset!top
          target -= 5px  # give a default margin
          #$.mobile.silent-scroll target
          $ 'html, body' .animate {scroll-top: target}, 500
        catch
          # pass

  if page.length is 1
    # example: #abcd
    # this is a anchor, just navigate to it
    scroll-to-anchor page.0
  else
    #          #/aaaa             : aaaa is page
    #          #/aaaa/bbbb        : aaaa is page, bbbb is anchor


    main-section = if page.1? and page.1.length > 0 then
      page.1
    else
      'home-page'
    anchor = page.2

    console.log "page is changed to #{main-section} / #{anchor}"
    $ ':mobile-pagecontainer' .pagecontainer 'change', ('#' + main-section)

    scroll-to-anchor anchor
    $ document .on \pageshow, ->
      scroll-to-anchor anchor
      $ document .off \pageshow

RactivePartial! .register-for-post-ready ->
  handle-navigation!
  $ window .on \hashchange, ->
    handle-navigation!

# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!
