ace = require('brace');
require('brace/mode/javascript')
require('brace/theme/monokai')
require 'brace/mode/livescript'

Ractive.components['ace-editor'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        e = ace.edit @find \*

        mode = @get \mode
        theme = switch @get('theme')
            | \dark => \monokai
            |_ => \xcode

        e.set-theme "ace/theme/#{theme}"
        e.get-session!set-mode "ace/mode/#{mode}"
        e.$blockScrolling = Infinity

        setting = null
        getting = null
        @observe \code, (val) ~>
            return if getting
            setting := yes
            e.set-value(val or '')
            e.clear-selection!
            setting := no


        e.on \change, ~>
            console.log "editor change..."
            getting := true
            @set \code, e.get-value!
            getting := false

    data: ->
        theme: \light
        mode: \javascript
