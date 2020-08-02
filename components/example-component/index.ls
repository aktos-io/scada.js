Ractive.components['example-component'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes

    oninit: ->
        @observe \birth, ->
            @set \age, (2016 - (@get \birth))

    data: ->
        age: 0
        birth: 0 
