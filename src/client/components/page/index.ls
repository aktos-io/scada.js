component-name = "page"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    data: ->
        is-selected: (url) ->
            url is "\#/#{@get 'name'}"
