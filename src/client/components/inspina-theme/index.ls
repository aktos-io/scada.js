require! './inspina-menu'
require! './inspina-theme'
require! './inspina-header'
require! './inspina-content'
require! './inspina-footer'

component-name = "inspina-right"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
