{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

table-data=
    * siparis-no: "123"
      tarih: "10.06"
      sube: "orası-burası-şurası"
      urun-sayisi: "5"
      tutar: "100"
    * siparis-no: "234"
      tarih: "11.06"
      sube: "orası-burası-şurası"
      urun-sayisi: "2"
      tutar: "150"
    * siparis-no: "345"
      tarih: "12.06"
      sube: "orası-burası-şurası"
      urun-sayisi: "10"
      tutar: "310"
    * siparis-no: "456"
      tarih: "13.06"
      sube: "orası-burası-şurası"
      urun-sayisi: "3"
      tutar: "50"

ractive = new Ractive do
    el: '#example_container'
    template: '#mainTemplate'
    data:
        table: table-data
        editable: false
        clicked-index: void

ractive.on do
    activated: (...args) ->
        index = args.0.index.i
        console.log "activated!!!", index
        ractive.set \clickedIndex, index
