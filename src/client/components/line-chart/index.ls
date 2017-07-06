require! 'c3'
require! 'prelude-ls':{empty}
require! uuid4
require! 'aea': {get-style-value}

colors =
    red: \#db2828
    orange: \#f2711c
    yellow: \#fbbd08
    olive: \#b5cc18
    green: \#21ba45
    teal: \#00b5ad
    blue: \#2185d0
    violet: \#6435c9
    purple: \#a333c8
    pink: \#e03997
    brown: \#a5673f
    grey: \#767676
    black: \#1b1c1d


Ractive.components['line-chart'] = Ractive.extend do
    template: '
        <div class="chart {{class}}"
            style="
                {{#if height}}height: {{height}};{{/if}}
                {{#if width}}width: {{width}};{{/if}}
                ">
            <div id="chart" data-name="{{id}}"></div>
        </div>
        '

    isolated: yes
    oninit: ->
        @set \id, uuid4!
    onrender: ->
        chart-area = @find "[data-name='#{@get "id"}']"
        chart = c3.generate do
            bindto: chart-area
            data:
                x: \timestamp
                columns:
                    ['timestamp']
                    ['data']

            color:
                pattern: [colors.teal]

            point: show: no 


        @observe \data, (_new) ->
            if (typeof! _new isnt \Array) or (empty _new)
                return
            try
                x = ['timestamp']
                y = ['data']
                for point in _new
                    x.push point.key
                    y.push point.value

                chart.flow do
                    columns: [x, y]

            catch
                console.error "line-chart error: ", e, _new
