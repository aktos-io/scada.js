/**
 * Minified by jsDelivr using UglifyJS v3.1.10.
 * Original file: /npm/ractive-transitions-fade@0.3.1/dist/ractive-transitions-fade.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t():"function"==typeof define&&define.amd?define(t):e.Ractive.transitions.fade=t()}(this,function(){"use strict";var e={delay:0,duration:300,easing:"linear"};return function(t,n){var i;n=t.processParams(n,e),t.isIntro?(i=t.getStyle("opacity"),t.setStyle("opacity",0)):i=0,t.animateStyle("opacity",i,n).then(t.complete)}});
//# sourceMappingURL=/sm/e87f61ed63244a135893a1f56c4568e089b066ea27449a001ebede9ad929c996.map