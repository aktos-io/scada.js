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
        
    RactivePartial! .init-for-dynamic-pos widget-positions
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
  
  ``
  

// target elements with the "draggable" class
interact('.draggable')
  .draggable({
    // enable inertial throwing
    inertia: true,
    // keep the element within the area of it's parent
    restrict: {
      restriction: "parent",
      endOnly: true,
      elementRect: { top: 0, left: 0, bottom: 1, right: 1 }
    },

    // call this function on every dragmove event
    onmove: dragMoveListener,
    // call this function on every dragend event
    onend: function (event) {
      var textEl = event.target.querySelector('p');

      textEl && (textEl.textContent =
        'moved a distance of '
        + (Math.sqrt(event.dx * event.dx +
                     event.dy * event.dy)|0) + 'px');
    }
  });

  function dragMoveListener (event) {
    var target = event.target,
        // keep the dragged position in the data-x/data-y attributes
        x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx,
        y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy;

    // translate the element
    target.style.webkitTransform =
    target.style.transform =
      'translate(' + x + 'px, ' + y + 'px)';

    // update the posiion attributes
    target.setAttribute('data-x', x);
    target.setAttribute('data-y', y);
  }

  // this is used later in the resizing demo
  window.dragMoveListener = dragMoveListener;

  ``
  
      
      
  
# TODO: remove this
# workaround for seamless page refresh
$ '#reload' .click -> location.reload!



    
  