# Ractive definition
ractive = new Ractive do
    oninit: ->
        @on do
            toggle-menu: ->
                @set \showMenu, not (@get \showMenu)
                console.log "show menu...", @get \showMenu

            hide-menu: ->
                @set \hideMenuValue, not (@get \hideMenuValue)
                console.log "hide menu value...", @get \hideMenuValue

    el: '#main-output'
    template: '#main-template'
    data:
        hide-menu-value: true
        menu:
            * title: "Bar Chart"
              url: 'app/bar-chart.html'
              icon: "resize-horizontal"
            * title: "Pie Chart"
              url: 'app/pie-chart.html'
              icon: "fire"
            * title: "Stacked Bar Chart"
              url: 'app/stacked-bar-chart.html'
              icon: "signal"
            * title: "Line Chart"
              url: 'app/line-chart.html'
              icon: "arrow-right"
            * title: "Interactive Table"
              url: 'app/table.html'
              icon: "random "
            * title: "Urun Iade Page"
              url: 'app/urun-iade.html'
              icon: "thumbs-up"

        show-menu: true
