component-name = "inspina-theme"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-menu"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->

    data:
        menu:
            * title: "Charts"
              sub-menu: 
                * title: "Bar Chart"
                  url: 'app/bar-chart.html'
                  icon: "resize-horizontal"
                * title: "Line Chart"
                  url: 'app/line-chart.html'
                  icon: "arrow-right"
                * title: "Interactive Table"
                  url: 'app/table.html'
                  icon: "random "
            * title: "Pie Chart"
              url: 'app/pie-chart.html'
              icon: "fire"
            * title: "Stacked Bar Chart"
              url: 'app/stacked-bar-chart.html'
              icon: "signal"


component-name = "inspina-right"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-header"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-content"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"

component-name = "inspina-footer"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
