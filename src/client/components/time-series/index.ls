require! 'rickshaw':Rickshaw
require! 'uuid4'
require! 'prelude-ls': {empty}

Ractive.components['time-series'] = Ractive.extend do
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

        serie = []
        graph = new Rickshaw.Graph do
            element: chart-area
            series:
                * color: 'steelblue',
                  data: serie
                ...

        graph.render();

        @observe \data, (_new) ->
            if (typeof! _new isnt \Array) or (empty _new)
                return
            try
                for point in _new
                    serie.push {x: point.key, y: point.value}

                graph.update!
            catch
                console.error "time-series error: ", e, _new
