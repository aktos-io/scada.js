/**
 * Minified by jsDelivr using UglifyJS v3.0.24.
 * Original file: /npm/ractive-transitions-fly@0.3.0/dist/ractive-transitions-fly.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):t.Ractive.transitions.fly=e()}(this,function(){"use strict";function t(t){return 0===t||"string"==typeof t?t:t+"px"}var e={duration:400,easing:"easeOut",opacity:0,x:-500,y:0};return function(n,o){var i={transform:"translate("+t((o=n.processParams(o,e)).x)+","+t(o.y)+")",opacity:0},r=void 0;n.isIntro?(r=n.getStyle(["opacity","transform"]),n.setStyle(i)):r=i,n.animateStyle(r,o).then(n.complete)}});
//# sourceMappingURL=/sm/24f5ec0b26076ceb6e0ca9a29ed53f82e4e5fb01baed0a9ccac5161dacb33826.map