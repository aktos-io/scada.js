/*

	ractive-transitions-fade
	========================

	Version 0.1.2.

	This plugin does exactly what it says on the tin - it fades elements
	in and out, using CSS transitions. You can control the following
	properties: `duration`, `delay` and `easing` (which must be a valid
	CSS transition timing function, and defaults to `linear`).

	The `duration` property is in milliseconds, and defaults to 300 (you
	can also use `fast` or `slow` instead of a millisecond value, which
	equate to 200 and 600 respectively). As a shorthand, you can use
	`intro='fade:500'` instead of `intro='fade:{"duration":500}'` - this
	applies to many other transition plugins as well.

	If an element has an opacity other than 1 (whether directly, because
	of an inline style, or indirectly because of a CSS rule), it will be
	respected. You can override the target opacity of an intro fade by
	specifying a `to` property between 0 and 1.

	==========================

	Troubleshooting: If you're using a module system in your app (AMD or
	something more nodey) then you may need to change the paths below,
	where it says `require( 'Ractive' )` or `define([ 'Ractive' ]...)`.

	==========================

	Usage: Include this file on your page below Ractive, e.g:

	    <script src='lib/ractive.js'></script>
	    <script src='lib/ractive-transitions-fade.js'></script>

	Or, if you're using a module loader, require this module:

	    // requiring the plugin will 'activate' it - no need to use
	    // the return value
	    require( 'ractive-transitions-fade' );

	Add a fade transition like so:

	    <div intro='fade'>this will fade in</div>

*/

(function ( global, factory ) {

	'use strict';

	// Common JS (i.e. browserify) environment
	if ( typeof module !== 'undefined' && module.exports && typeof require === 'function' ) {
		factory( require( 'ractive' ) );
	}

	// AMD?
	else if ( typeof define === 'function' && define.amd ) {
		define([ 'ractive' ], factory );
	}

	// browser global
	else if ( global.Ractive ) {
		factory( global.Ractive );
	}

	else {
		throw new Error( 'Could not find Ractive! It must be loaded before the ractive-transitions-fade plugin' );
	}

}( typeof window !== 'undefined' ? window : this, function ( Ractive ) {

	'use strict';

	var fade, defaults;

	defaults = {
		delay: 0,
		duration: 300,
		easing: 'linear'
	};

	fade = function ( t, params ) {
		var targetOpacity;

		params = t.processParams( params, defaults );

		if ( t.isIntro ) {
			targetOpacity = t.getStyle( 'opacity' );
			t.setStyle( 'opacity', 0 );
		} else {
			targetOpacity = 0;
		}

		t.animateStyle( 'opacity', targetOpacity, params ).then( t.complete );
	};

	Ractive.transitions.fade = fade;

}));
