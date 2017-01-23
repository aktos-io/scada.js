# Since both the components' name is `aea-menu` they MUST be used interchangeably
# So if one's uncommented, the other MUST be commented out
# require! './aea-menu'
require! './aea-menu2'

component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')
