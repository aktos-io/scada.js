/**
 * Minified by jsDelivr using UglifyJS v3.4.4.
 * Original file: /npm/ractive-transitions-fly@0.3.0/dist/ractive-transitions-fly.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):t.Ractive.transitions.fly=e()}(this,function(){"use strict";var i={duration:400,easing:"easeOut",opacity:0,x:-500,y:0};function r(t){return 0===t||"string"==typeof t?t:t+"px"}return function(t,e){var n={transform:"translate("+r((e=t.processParams(e,i)).x)+","+r(e.y)+")",opacity:0},o=void 0;t.isIntro?(o=t.getStyle(["opacity","transform"]),t.setStyle(n)):o=n,t.animateStyle(o,e).then(t.complete)}});
//# sourceMappingURL=/sm/c9e3bb63a4963764f265cad842a971829c77e5e37c24460881fec7966ada85d6.map