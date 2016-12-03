component-name = "example-component"

Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: yes

    oninit: ->
        @observe \birth, ->
            @set \age, (2016 - (@get \birth))
