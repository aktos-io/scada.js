Ractive.components['issues'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    data: ->
        settings: require './data-table' .settings
