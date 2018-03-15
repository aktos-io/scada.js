/**
 * Minified by jsDelivr using UglifyJS v3.1.10.
 * Original file: /npm/ractive-transitions-slide@0.4.0/dist/ractive-transitions-slide.umd.js
 * 
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):(t.Ractive=t.Ractive||{},t.Ractive.transitions=t.Ractive.transitions||{},t.Ractive.transitions.slide=e())}(this,function(){"use strict";var t={duration:300,easing:"easeInOut"},e=["height","borderTopWidth","borderBottomWidth","paddingTop","paddingBottom","marginTop","marginBottom"],o={height:0,borderTopWidth:0,borderBottomWidth:0,paddingTop:0,paddingBottom:0,marginTop:0,marginBottom:0};return function(i,n){var d;n=i.processParams(n,t),i.isIntro?(d=i.getStyle(e),i.setStyle(o)):(i.setStyle(i.getStyle(e)),d=o),i.setStyle("overflowY","hidden"),i.animateStyle(d,n).then(i.complete)}});
//# sourceMappingURL=/sm/50f1bda294c9adf94705e904706120e097e366f763103942458b95208b95f18b.map