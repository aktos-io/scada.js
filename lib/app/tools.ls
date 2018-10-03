window.sleep = (ms, f) -> set-timeout f, ms

# Cached version of $.getScript
window.getScriptCached = getScriptCached = (url, callback) ->
    jQuery.ajax do
            type: "GET"
            url: url
            success: ->
                callback!
            error: (XMLHttpRequest, textStatus, errorThrown) ->
                callback {error: XMLHttpRequest}
            dataType: "script"
            cache: true

# Simpler version of $.getScriptCached
``
// taken from https://stackoverflow.com/a/28002292/1952991

window.getScript = function(source, callback) {
    var script = document.createElement('script');
    var prior = document.getElementsByTagName('script')[0];
    script.async = 1;

    script.onload = script.onreadystatechange = function( _, isAbort ) {
        if(isAbort || !script.readyState || /loaded|complete/.test(script.readyState) ) {
            script.onload = script.onreadystatechange = null;
            script = undefined;

            if(!isAbort) { if(callback) callback(); }
        }
    };
    script.src = source;
    prior.parentNode.insertBefore(script, prior);
}
``

# load CSS files, taken from https://stackoverflow.com/a/5537911/1952991
``
function loadStyleSheet( path, fn, scope ) {
   var timeout = 30000; // long duration for extemely slow connections
   var head = document.getElementsByTagName( 'head' )[0], // reference to document.head for appending/ removing link nodes
       link = document.createElement( 'link' );           // create the link node
   link.setAttribute( 'href', path );
   link.setAttribute( 'rel', 'stylesheet' );
   link.setAttribute( 'type', 'text/css' );

   var sheet, cssRules;
// get the correct properties to check for depending on the browser
   if ( 'sheet' in link ) {
      sheet = 'sheet'; cssRules = 'cssRules';
   }
   else {
      sheet = 'styleSheet'; cssRules = 'rules';
   }

   var interval_id = setInterval( function() {                     // start checking whether the style sheet has successfully loaded
          try {
             if ( link[sheet] && link[sheet][cssRules].length ) { // SUCCESS! our style sheet has loaded
                clearInterval( interval_id );                      // clear the counters
                clearTimeout( timeout_id );
                fn.call( scope || window, true, link );           // fire the callback with success == true
             }
          } catch( e ) {} finally {}
       }, 10 ),                                                   // how often to check if the stylesheet is loaded
       timeout_id = setTimeout( function() {       // start counting down till fail
          clearInterval( interval_id );             // clear the counters
          clearTimeout( timeout_id );
          //head.removeChild( link );                // let the system load the style sheet asynchronously
          fn.call( scope || window, false, link ); // fire the callback with success == false
       }, timeout );                                 // how long to wait before failing

   head.appendChild( link );  // insert the link node into the DOM and start loading the style sheet

   return link; // return the link node;
}
``
window.getDep = (filename, callback) !->
    ext = filename.split '.' .pop!
    switch ext
    | \js   =>
        # TODO: Take the following into account:
        /*
        script if (typeof module === 'object') {window.module = module; module = undefined;}
        script#vendor(src="js/vendor.js")
        script if (window.module) module = window.module;
        */
        getScript filename, callback
    | \css  => loadStyleSheet filename, callback


# useful for pretty formatting
window.oneDecimal = (x) -> parseFloat(Math.round(x * 10) / 10).toFixed(1)

require! './error'
