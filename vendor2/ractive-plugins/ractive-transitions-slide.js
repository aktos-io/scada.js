/**
 * Minified by jsDelivr using UglifyJS v3.4.4.
 * Original file: /npm/ractive-transitions-slide@0.4.0/dist/ractive-transitions-slide.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):(t.Ractive=t.Ractive||{},t.Ractive.transitions=t.Ractive.transitions||{},t.Ractive.transitions.slide=e())}(this,function(){"use strict";var i={duration:300,easing:"easeInOut"},n=["height","borderTopWidth","borderBottomWidth","paddingTop","paddingBottom","marginTop","marginBottom"],d={height:0,borderTopWidth:0,borderBottomWidth:0,paddingTop:0,paddingBottom:0,marginTop:0,marginBottom:0};return function(t,e){var o;e=t.processParams(e,i),t.isIntro?(o=t.getStyle(n),t.setStyle(d)):(t.setStyle(t.getStyle(n)),o=d),t.setStyle("overflowY","hidden"),t.animateStyle(o,e).then(t.complete)}});
//# sourceMappingURL=/sm/16beaf09e6af6b5882a41ac2aa4d6322f141326ee582cda31ca55b22807c1690.map