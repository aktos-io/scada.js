require! {
  '../modules/aktos-dcs': {
    ProxyActor,
    RactivePartial,
    SwitchActor,
    RactiveApp, 
  }
}
  
# include widgets' initialize codes 
require '../partials/ractive-partials'
  
# Set Ractive.DEBUG to false when minified:
Ractive.DEBUG = /unminified/.test !-> /*unminified*/

app = new Ractive do
  el: 'container'
  template: '#app'
  data: 
    abc: 123

RactiveApp!set app

# Create the actor which will connect to the server
proxy-actor = ProxyActor!

app.on 'complete', !->
  #console.log "window.location: ", window.location
  if not window.location.hash
    window.location = '#home-page'
   
  # create actors and init widgets
  RactivePartial! .init!

  # debugging purposes
  #test = SwitchActor 'test-actor'

  $ document .ready ->
    console.log "document is ready..."
    RactivePartial! .init-for-document-ready!
        
    # debug 
    /*
    test.send IoMessage:
      pin_name: 'test-pin'
      val: on
    */

  
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
      
      
  
# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!



    
  