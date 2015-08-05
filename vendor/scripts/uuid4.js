/*jslint bitwise: true, indent: 2, nomen: true, regexp: true, stupid: true*/
var UUID = (function () {
  'use strict';

  var exports = {};

  exports.uuid4 = function () {
    //// return uuid of form xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    var uuid = '', ii;
    for (ii = 0; ii < 32; ii += 1) {
      switch (ii) {
      case 8:
      case 20:
        uuid += '-';
        uuid += (Math.random() * 16 | 0).toString(16);
        break;
      case 12:
        uuid += '-';
        uuid += '4';
        break;
      case 16:
        uuid += '-';
        uuid += (Math.random() * 4 | 8).toString(16);
        break;
      default:
        uuid += (Math.random() * 16 | 0).toString(16);
      }
    }
    return uuid;
  };

  //// test
  ///console.log(exports.uuid4());

  window.uuid4 = exports.uuid4

}());
