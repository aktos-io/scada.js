require! {
  '../modules/aktos-dcs': {
    ProxyActor,
    RactivePartial,
    get-ractive-var, 
    set-ractive-var, 
    SwitchActor,
    RactiveApp, 
  }
}
  
# include widgets' initialize codes 
require '../partials/ractive-partials'

set-switch-actors = !->
  $ '.switch-actor' .each !->
    elem = $ this
    pin-name = get-ractive-var elem, 'pin_name'
    actor = SwitchActor pin-name
    actor.set-node elem
    elem.data \actor, actor
  
# Set Ractive.DEBUG to false when minified:
Ractive.DEBUG = /unminified/.test !-> /*unminified*/

app = new Ractive do
  el: 'container'
  template: '#app'

RactiveApp!set app

# Create the actor which will connect to the server
ProxyActor!

RactivePartial! .register-for-document-ready ->

  $ '.toolbar-icons a' .on \click, (event) ->
    event.preventDefault!
    
  $ 'div[data-toolbar="hide-option"]' .toolbar do
    content: '#transport-options',
    position: 'top',
    style: 'primary',
    event: 'click',
    hideOnClick: true
    

app.on 'complete', !->
  #console.log "window.location: ", window.location
  if not window.location.hash
    window.location = '#home-page'
   
  # create actors and init widgets
  set-switch-actors!
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
      
      
  
# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!



    
  