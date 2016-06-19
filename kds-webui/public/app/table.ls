{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

data-from-webservice =
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


decorate-table-data = (table-data) ->
    #[{siparis-no: ..siparis-no, tarih: ..tarih, sube: ..sube, urun-sayisi: ..urun-sayisi, tutar: "#{..tutar} TL"} for table-data]
    #console.log "table-data..." , table-data
    [[..tarih, ..siparis-no, ..sube, ..urun-sayisi, ..tutar] for table-data]

InteractiveTable = Ractive.extend do
    oninit: ->
        col-list = @get \cols |> split ','
        @set \columnList, col-list

        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                @set \clickedIndex, index

            hide-menu: ->
                console.log "clicked to hide", (@get \clickedIndex)
                @set \clickedIndex, null
                @set \editable, no

    template: '#interactive-table'
    data:
        editable: false
        clicked-index: null
        cols: null
        column-list: null


x = decorate-table-data data-from-webservice

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: x
    components:
        'interactive-table': InteractiveTable


sleep = (ms, f) -> set-timeout f, ms

ractive.on \complete, ->
    <- :lo(op) ->
        console.log "x is: ", x.2.3
        <- sleep 2000ms
        lo(op)
