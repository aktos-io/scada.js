Ractive.components['example-component'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    oninit: ->
        # currentYear = new Date().getFullYear()
        # might be a better option
        @observe \birth, ->
            @set \age, (2017 - (@get \birth))
