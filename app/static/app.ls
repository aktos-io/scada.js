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
    
  console.log "ractive app completed..."
  
# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!
    
  