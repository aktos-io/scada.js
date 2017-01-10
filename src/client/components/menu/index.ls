component-name = "menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        @on do
            toggle-menu: ->
                @set \showMenu, not (@get \showMenu)
                #console.log "show menu...", @get \showMenu

            hide-menu: ->
                @set \hideMenuValue, not (@get \hideMenuValue)
                #console.log "hide menu value...", @get \hideMenuValue
    data: ->
        hide-menu-value: true
        menu:
            * title: "Set Menu Variable"
              url: 'app/bar-chart.html'
              icon: "resize-horizontal"
            ...
        show-menu: true

<-! $ \document .ready
ev <-! $ \.main-sidebar-button .click
$ \.main-sidebar .toggleClass \collapsed
