require! {
  '../modules/aktos-dcs': {
    ProxyActor,
    RactivePartial,
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

# Register ractive app in order to use in partials
RactiveApp!set app

# Create the actor which will connect to the server
proxy-actor = ProxyActor!

app.on 'complete', !->
  # create actors and init widgets
  RactivePartial! .init!

  $ document .ready ->
    console.log "document is ready..."
    RactivePartial! .init-for-document-ready!

    proxy-actor.update-connection-status!

    RactivePartial! .init-for-dynamic-pos widget-positions
    set-timeout (->
      RactivePartial! .init-for-post-ready!
      # Update all I/O on init
      ), 1000


  console.log "ractive app completed..."


# ----------------------------------------------------
#             All test code goes below
# ----------------------------------------------------
require! {
  '../modules/aktos-dcs': {
    SwitchActor,
  }
}

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

RactivePartial!register ->
  console.log "Testing sending data to table from app.ls"
  test = SwitchActor 'test-actor'
  test.send IoMessage:
    pin_name: \test-table
    table_data:
      <[ a b c d e ]>
      <[ a1 b1 c1 d1 e1 ]>
      <[ a2 b2 c2 d2 e2 ]>


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
