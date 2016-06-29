
{split, take, join, lists-to-obj, Str} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

BarChart = Ractive.extend do
    template: '#bar-chart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-short-name: (name) ->
            "#{Str.take 6, name}..."

my-data =
    * name: "son kullanma tarihi geçmiş"
      amount: 15
    * name: "müşteri iade"
      amount: 80
    * name: "hatalı sipariş"
      amount: 23

simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]


ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: my-data
        simulate-data: simulate-data
    components:
        "bar-chart": BarChart


{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
sleep = (ms, f) -> set-timeout f, ms


db = null
satis-listesi = null

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-table-data: null
        materials: []

ractive.on do
    update-table: ->
        console.log "updating satis listesi!", satis-listesi
        db.put satis-listesi, (err, res) ->
            console.log "satıs listesi (put): ", err, res
        <- sleep 1000ms
        console.log "satis-listesi: :: ", satis-listesi

db = new PouchDB \mydb
#remote = 'https://USERNAME:PASSWORD@USERNAME.cloudant.com/DB_NAME'

db.sync remote, {live: yes}

# ------------------- Database definition ends here ----------------------#

generate-entry-id = (user-id) -->
    timestamp = new Date!get-time! .to-string 16
    "#{user-id}-#{timestamp}"

get-entry-id = generate-entry-id 5


get-materials = ->
    db.query 'primitives/raw-material-list', (err, res) ->
        console.log "this document contains raw material list: ", res
        material-document = res.rows.0.id
        db.get material-document, (err, res) ->
            materials =  [..name for res.contents]
            console.log "these are materials: ", materials
            ractive.set \materials, materials


opts =
    since: 'now'
    live: true

db.changes opts .on 'change', (...x) ->
    console.log "change detected!", x
    get-materials!

db.info (...x) ->
    console.log "info ::: ", x

db.query 'getTitles/new-view', (err, res) ->
    console.log "getting titles: ", res
    db.all-docs {include_docs: yes, keys: [..key for res.rows]}, (err, res) ->
        console.log "documents related with titles: ", err, res


db.get "satış listesi", (err, res) ->
    satis-listesi := res
    console.log "satış listesi: ", satis-listesi
    ractive.set "myTableData", satis-listesi.entries


{maximum-by, last, sort-by, split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/


LineChart = Ractive.extend do
    template: '#line-chart'
    init: ->
        points = @get "points"
        @set "scaledPoints", @scaled-points
        scaled-points = @scaled-points!

        #console.log "a is: ", a
        x-labels = [0 to (last scaledPoints).x by 10]
        console.log "x-labels: ", x-labels
        @set "xLabels", x-labels


        height= @get \height
        y-labels = [0 to height by 50]
        console.log "y-labels: ", y-labels
        @set "yLabels", y-labels

    scaled-points: ->
        points = @get "points"
        sorted-x = sort-by (.x),points
        max-x = last sorted-x .x
        max-y = maximum-by (.y), points
        #console.log max-y.y
        width = @get \width
        height = @get \height
        #console.log height
        scale-factor-x = width / max-x
        scale-factor-y = height / max-y.y
        a = [{x: ..x * scale-factor-x, y: height - (..y * scale-factor-y)} for points]
        #console.log "scaled points are :", a
        a

    data:
        y-labels: null
        x-labels: null
        scaled-points: null

        convert-to-svg-points: (points) ->
            /* --------------------------------------
            converts points for the following format:

                @points =
                    * x: 1
                      y: 5
                    * x: 15
                      y: 16

            to:

                "1 5,15 16"
            ---------------------------------------- */
            scaled-points = @scaled-points!
            #console.log "djsdjkcnlkd: ", scaled-points
            x = join ' ' ["#{..x}, #{..y}" for points]
            console.log x
            x


# ------------------------------------------------------------ #
                # Edit only Below #
# ------------------------------------------------------------ #

my-data =
    * x: 1 # date
      y: 1.5 # amount
    * x: 3
      y: 4.5
    * x: 4
      y: 5.5
    * x: 5
      y: 3
    * x: 8.5
      y: 10
    * x: 10
      y: 0.8

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: my-data
    components:
        "line-chart": LineChart


{split, take, join, lists-to-obj, sum, sort} = require 'prelude-ls'
sleep = (ms, f) -> set-interval f, ms
Ractive.DEBUG = /unminified/.test -> /*unminified*/

PieChart = Ractive.extend do
    template: '#pie-chart'
    oninit: ->
        col-list = @get \names |> split ','
        @set \columnList, col-list
        self=@
        <- sleep @get \delay
        self.animate 'c', Math.PI * 2, do
            duration: 800
            easing: 'easeOut'

    init:(options)->
        @animate 'c' , Math.PI*2
    data:
        selected: null
        names: null
        column-list: null
        c: 0
        colors: <[ red green blue yellow ]>
        getSegments:(data)->
            total = sum data
            data = sort data
            start=0
            segments = data.map (x)->
                size = x / total
                end = start + size
                segment=
                    value: x
                    start: start
                    end: end
                start:=end
                segment
            console.log "segments: ", segments
            segments

        getSegmentPoints:(segment, innerRadius, outerRadius)->
            points=[]
            start = segment.start * @get \c
            end = segment.end * @get \c
            getPoint=(angle,radius)->( ( radius * Math.sin( angle ) ).toFixed( 2 ) + ',' + ( radius * -Math.cos( angle ) ).toFixed( 2 ) )
            for angle from start to end by 0.05
                points[ points.length ] = getPoint angle, outerRadius
            points[ points.length ] = getPoint end, outerRadius
            for angle from end to start by -0.05
                points[ points.length ] = getPoint angle, innerRadius
            points[ points.length ] = getPoint start, innerRadius
            #console.log "test:" , points.join ' '
            return points.join ' '

simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]
    x = [random! for reasons]


ractive=new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: [3,5,7,99]
        simulate-data: simulate-data
    components:
        piechart: PieChart


{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

StackedBarChart = Ractive.extend do
    template: '#stacked-bar-chart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-graph-data:(data-list) ->
            /* this function returns list of data points
                in order to draw a stacked progress bar.

                input data format:

                    input-data =
                        * name: "My data 1"
                          amount: amount1
                        * name: "My data 2"
                          amount: amount2

                data format is as follows:

                    points =
                        * name: "My data 1"
                          amount: amount1
                          start-x: 0
                          center-x: start-x + amount1 / 2
                        * name: "My data 2"
                          amount: amount2
                          start-x: 0 + amount1
                          center-x: start-x + amount2 / 2
                        * name: "My data 3"
                          amount: amount3
                          start-x: 0 + amount1 + amount2
                          center-x: start-x + amount3 / 2
                        ...
            */
            #console.log "data-list: " , data-list
            r = []
            for i in data-list
                #console.log "i : ", i
                data-point = {name: i.name, amount: i.amount}

                # add cumulative starting coordinate to each data point
                data-point.start-x = sum [..amount for r]
                data-point.center-x = data-point.start-x + (data-point.amount / 2)
                #console.log "sum: ", data-point.start-x

                r ++= [data-point]
                #console.log "r: ", r
            return r



my-data =
    * name: "son kullanma tarihi geçmiş"
      amount: 15
    * name: "müşteri iade"
      amount: 80
    * name: "hatalı sipariş"
      amount: 23

simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        simulate-data: simulate-data
        my-data: my-data
    components:
        'stacked-bar-chart': StackedBarChart


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
                    @fire \showModal
                @set \clickedIndex, index

            close-modal: ->
                self = @
                $ "\##{@get 'id'}-modal" .modal \hide
                <- sleep 300ms
                self.fire \giveTooltip


            give-tooltip: ->
                self = @
                i = 0
                <- :lo(op) ->
                    <- sleep 150ms
                    self.set \editTooltip, on
                    <- sleep 150ms
                    self.set \editTooltip, off
                    if ++i is 2
                        return op!
                    lo(op)


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


{split, take, join, lists-to-obj, Str} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

BarChart = Ractive.extend do
    template: '#bar-chart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-short-name: (name) ->
            "#{Str.take 6, name}..."



get-return-production= (product-name) ->
    x = [..production for my-data when ..name is product-name].0
    #console.log " X is , ", x
    #console.log "DEBUG: ",  x.0.planned


my-data =
    * name: \Haydari
      production:
          * date: "12.02.2005"
            planned: 24
            produced: 12

          * date: "12.12.2012"
            planned: 55
            produced: 33

          * date: "12.12.2016"
            planned: 123
            produced: 97

    * name: \Rus
      production:
          * date: "10.02.2005"
            planned: 24
            produced: 12

          * date: "10.12.2012"
            planned: 49
            produced: 45

          * date: "10.12.2016"
            planned: 96
            produced: 87

    * name: \Ezme
      production:
          * date: "01.01.2012"
            planned: 9
            produced: 9

          * date: "02.03.2013"
            planned: 22
            produced: 19

          * date: "23.11.2016"
            planned: 23
            produced: 46


ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        my-data: my-data
        get-return-production: get-return-production
    components:
        "bar-chart": BarChart


{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
Ractive.DEBUG = /unminified/.test -> /*unminified*/

StackedBarChart = Ractive.extend do
    template: '#stackedchart'
    data:
        get-color: (order) ->
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            console.log "color: ", colors[order]
            colors[order]

        get-graph-data:(data-list) ->
            /* this function returns list of data points
                in order to draw a stacked progress bar.

                input data format:

                    input-data =
                        * name: "My data 1"
                          amount: amount1
                        * name: "My data 2"
                          amount: amount2

                data format is as follows:

                    points =
                        * name: "My data 1"
                          amount: amount1
                          start-x: 0
                          center-x: start-x + amount1 / 2
                        * name: "My data 2"
                          amount: amount2
                          start-x: 0 + amount1
                          center-x: start-x + amount2 / 2
                        * name: "My data 3"
                          amount: amount3
                          start-x: 0 + amount1 + amount2
                          center-x: start-x + amount3 / 2
                        ...
            */
            console.log "data-list: " , data-list
            r = []
            for i in data-list
                console.log "i : ", i
                data-point = {name: i.name, amount: i.amount}

                # add cumulative starting coordinate to each data point
                data-point.start-x = sum [..amount for r]
                data-point.center-x = data-point.start-x + (data-point.amount / 2)
                console.log "sum: ", data-point.start-x

                r ++= [data-point]
                console.log "r: ", r
            return r



# ------------------------------------------------------------------------- #
                    # edit only below #
# ------------------------------------------------------------------------- #


convert-reason-to-sbc = (x) ->
    r = [name: ..reason, amount: ..amount for x]
    console.log "...: ", r
    r


get-return-reasons = ->
    names =
        "Haydari"
        "Rus salata"
        "Mercimek"
        "İçli Köfte"
        "Sarma"
        "Dolma"
        "Patlıcan Ezme"
        "Biber Dolma"
        "Patates Közleme"
        "Balık Buğulama"
        "Ayva Güllacı"
        "Mahmut Beğendi"

    reasons = <[
        SKT
        AAA
        BBB
        CCC
    ]>

    random = -> parse-int (Math.random! * 100)

    [{name: .., return-reasons: [{reason: .., amount: random!} for reasons]} for names]

return-reasons =
    * name: \Haydari
      return-reasons:
          * reason: "son kullanma tarihi geçmiş"
            amount: 15
          * reason: "müşteri iade"
            amount: 80
          * reason: "hatalı sipariş"
            amount: 23

    * name: "Rus Salatası"
      return-reasons:
          * reason: "son kullanma tarihi geçmiş"
            amount: 11
          * reason: "müşteri iade"
            amount: 35
          * reason: "hatalı sipariş"
            amount: 49

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        return-reasons: get-return-reasons!
        convert-reason-to-sbc: convert-reason-to-sbc
    components:
        'stacked-bar-chart': StackedBarChart

