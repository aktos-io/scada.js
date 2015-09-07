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
tmp = ->
  ``
                        jQuery(document).ready(function($) {

                                // Define any icon actions before calling the toolbar
                                $('.toolbar-icons a').on('click', function( event ) {
                                        event.preventDefault();
                                });

                                $('div[data-toolbar="user-options"]').toolbar({
                                    content: '#user-options',
                                    position: 'top',
                                });

                                $('div[data-toolbar="transport-options"]').toolbar({
                                    content: '#transport-options',
                                    position: 'top',
                                });             

                                $('div[data-toolbar="transport-options-o"]').toolbar({
                                    content: '#transport-options-o',
                                    position: 'bottom',
                                    event: 'click',
                                    hideOnClick: true,
                                });                                                                     

                                $('div[data-toolbar="content-option"]').toolbar({
                                    content: '#transport-options',
                                });             

                                $('div[data-toolbar="position-option"]').toolbar({
                                    content: '#transport-options',
                                    position: 'bottom',
                                });

                                $('div[data-toolbar="style-option"]').toolbar({
                                    content: '#transport-options',
                                    position: 'bottom',
                                    style: 'primary',
                                });

                                $('div[data-toolbar="animation-option"]').toolbar({
                                    content: '#transport-options',
                                    position: 'bottom',
                                    style: 'primary',
                                    animation: 'flyin'
                                });

                                $('div[data-toolbar="event-option"]').toolbar({
                                    content: '#transport-options',
                                    position: 'bottom',
                                    style: 'primary',
                                    event: 'click',
                                });                                                             

                                $('div[data-toolbar="hide-option"]').toolbar({
                                    content: '#transport-options',
                                    position: 'bottom',
                                    style: 'primary',
                                    event: 'click',
                                    hideOnClick: true
                                });                                                             

                                $('#link-toolbar').toolbar({
                                        content: '#user-options', 
                                        position: 'top',
                                        event: 'click',
                                        adjustment: 35
                                });

                                $('div[data-toolbar="set-01"]').toolbar({
                                    content: '#set-01-options',
                                    position: 'top',
                                });     

                                $('div[data-toolbar="set-02"]').toolbar({
                                    content: '#set-02-options',
                                    position: 'left',
                                });     

                                $('div[data-toolbar="set-03"]').toolbar({
                                    content: '#set-03-options',
                                    position: 'bottom',
                                });     

                                $('div[data-toolbar="set-04"]').toolbar({
                                    content: '#set-04-options',
                                    position: 'right',
                                });     

                                $(".download").on('click', function() {
                                        mixpanel.track("Toolbar.Download");
                                });

                                $("#transport-options-2").find('a').on('click', function() {
                                        $this = $(this);
                                        $button = $('div[data-toolbar="transport-options-2"]');
                                        $newClass = $this.find('i').attr('class').substring(3);
                                        $oldClass = $button.find('i').attr('class').substring(3);
                                        if($newClass != $oldClass) {
                                                $button.find('i').animate({
                                                        top: "+=50",
                                                        opacity: 0
                                                }, 200, function() {
                                                        $(this).removeClass($oldClass).addClass($newClass).css({top: "-=100", opacity: 1}).animate({
                                                                top: "+=50"     
                                                        });
                                                });
                                        }

                                });

                                $('div[data-toolbar="transport-options-2"]').toolbar({
                                    content: '#transport-options-2',
                                    position: 'top',
                                });     


                        });
  ``
  $ \#mesut .each ->
    $ this .toolbar do
      content: \#toolbar-options
      style: \primary
      position: \bottom
      event: \click
      hide-on-click: on
    console.log "toolbar function is running"

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
    tmp!

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



    
  