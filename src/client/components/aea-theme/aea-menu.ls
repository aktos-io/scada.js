Ractive.components["aea-menu"] = Ractive.extend do
    template: RACTIVE_PREPARSE('aea-menu.pug')
    isolated: yes
    data: ->
        expand: yes
