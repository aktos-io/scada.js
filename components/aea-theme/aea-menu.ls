Ractive.components["aea-menu"] = Ractive.extend do
    template: require('./aea-menu.pug')
    isolated: yes
    data: ->
        expand: yes
