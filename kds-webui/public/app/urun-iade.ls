{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:{}
