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

RactiveApp!set app

# Create the actor which will connect to the server
ProxyActor!

app.on 'complete', !->
  #console.log "window.location: ", window.location
  if not window.location.hash
    window.location = '#home-page'
   
  # create actors and init widgets
  RactivePartial! .init!

  $ document .ready ->
    console.log "document is ready..."
    RactivePartial! .init-for-document-ready!
        
    test.send IoMessage:
      pin_name: 'test-pin'
      val: on

    
  console.log "ractive app completed..."
  
  test = SwitchActor 'test-actor'
  test.send IoMessage:
    pin_name: \test-table
    table_data:
      * <[ bir iki üç dört beş ]>
      * <[ 1bir 1iki 1üç 1dört 1beş ]>
      * <[ 2bir 2iki 2üç 2dört 2beş ]>
      
  test2 = SwitchActor \gauge-slider
  
  i = 0
  j = +1
  up = -> 
    test2.gui-event i
    if i >= 100 
      j := -1 
    if i <= 0 
      j := +1
    i := i + j
    set-timeout up, 10
    
  #set-timeout up, 5000
    
  
      
      
  
# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!



    
  