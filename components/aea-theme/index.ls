require! './aea-menu'
require! './aea-menu2'

component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: require('index.pug', '#aea-theme')

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: require('index.pug', '#aea-content')
