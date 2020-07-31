/**
 * Minified by jsDelivr using UglifyJS v3.4.4.
 * Original file: /npm/ractive-transitions-fade@0.3.1/dist/ractive-transitions-fade.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t():"function"==typeof define&&define.amd?define(t):e.Ractive.transitions.fade=t()}(this,function(){"use strict";var i={delay:0,duration:300,easing:"linear"};return function(e,t){var n;t=e.processParams(t,i),e.isIntro?(n=e.getStyle("opacity"),e.setStyle("opacity",0)):n=0,e.animateStyle("opacity",n,t).then(e.complete)}});
//# sourceMappingURL=/sm/908fb53bbf5de26405d7157f9ca2b72161e5329879e94c0d5bb71811da809417.map