{split, take, join, lists-to-obj} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        kds:''
        products:[9]
    components:
        "bar-chart": BarChart
