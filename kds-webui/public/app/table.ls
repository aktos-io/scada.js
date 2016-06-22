{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

sleep = (ms, f) -> set-timeout f, ms

InteractiveTable = Ractive.extend do
    oninit: ->
        col-list = @get \cols |> split ','
        @set \columnList, col-list
        self = @
        console.log "table content", @get \content

        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                curr-index = @get \clickedIndex
                if index is curr-index
                    console.log "Give tooltip!"
                    i = 0
                    @fire \showModal
                    <- sleep 1000ms
                    <- :lo(op) ->
                        <- sleep 150ms
                        self.set \editTooltip, on
                        <- sleep 150ms
                        self.set \editTooltip, off
                        if ++i is 2
                            return op!
                        lo(op)

                @set \clickedIndex, index

            hide-menu: ->
                console.log "clicked to hide", (@get \clickedIndex)
                @set \clickedIndex, null
                @set \editable, no

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            revert: ->
                alert "Changes Reverted!"

            show-modal: ->
                id = @get \id
                console.log "My id: ", id
                $ "\##{id}-modal" .modal \show

    template: '#interactive-table'
    data:
        editable: false
        clicked-index: null
        cols: null
        column-list: null
        editTooltip: no
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)

# ------------------------------------------------------------------ #
#                       Example page starts below                    #
# ------------------------------------------------------------------ #

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
