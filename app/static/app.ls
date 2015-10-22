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
  data:
    gms: {}

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


RactivePartial!register ->
  poll-gms = ->
    $.ajax do
      method: "GET"
      url: "gms/WebService1.asmx/GetRooms"
      data-type: 'json'
      success: (response) ->
        console.log "got gms data..."
        app.set \gms, response

  poll-gms!
  set-interval poll-gms, 30_000ms


RactivePartial!register ->
  projects =
    * label: 'Cici Meze'
      src: 'projects/akhisar-atiksu/proje-kapak.jpg'
      addr: '#/cici-meze'

    * label: 'Akhisar Atıksu Arıtma'
      src: 'projects/akhisar-atiksu/proje-kapak.jpg'
      addr: '#akhisar-atiksu'

    * label: 'Doğanbey Atıksu Arıtma'
      src: 'projects/doganbey-atiksu/tesis-ustten.jpg'
      addr: '#doganbey-atiksu'

    * label: 'Delphi Otomativ (İzmir)'
      src: 'projects/delphi-kablo-zirhi-soyma/proje-kapak.jpg'
      addr: '#delphi-otomativ-izmir'

    * src: 'projects/hms-telemetri/proje-kapak.jpg'
      label: 'HMS Üretim Takip'

    * src: 'projects/iski/scada.jpg'
      label: 'İski Terfi İstasyonu'

    * src: 'projects/lintek-newtech-cep-otomati/cep-otomati-onden-1.jpg'
      label: 'Newtech Cep Otomatı'

    * src: 'projects/versis-asfalt-plenti/proje-kapak.jpg'
      label: 'Versis Asfalt Plenti'

    * src: 'projects/serel/proje-kapak.jpg'
      label: 'Serel Seramik Üretim Takip'

    * src: 'projects/kku-nukleer-fizik-lab/proje-kapak.jpg'
      label: 'Gama-Gama Korelasyon Deney Otomasyonu'

  app.set \page.projects, projects



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
