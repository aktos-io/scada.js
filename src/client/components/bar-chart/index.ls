component-name = "bar-chart"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    oninit: ->
        name= @get \name
        @set \name, name
    data: ->
        name:null
        get-color: (order) ->
            console.log "renk"
            colors = <[ #d9534f #5bc0de #5cb85c #f0ad4e #337ab7 ]>
            colors[order]

        get-short-name: (name) ->
            console.log "func içinde: ", name
            "#{Str.take 6, name}..."
