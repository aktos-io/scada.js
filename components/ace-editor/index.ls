ace = require 'brace'
require 'brace/mode/javascript'
require 'brace/mode/livescript'
require 'brace/theme/monokai'
require 'brace/theme/xcode'
require 'brace/ext/searchbox'

Ractive.components['ace-editorASYNC'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        editor = ace.edit @find \*

        @observe \theme, (_theme) ->
            if _theme
                theme = switch _theme
                    | \dark => \monokai
                    | \light => \xcode
                    |_ => that
                editor.set-theme "ace/theme/#{theme}"

        @observe \mode, (mode) ~>
            editor.get-session!.set-mode "ace/mode/#{mode}"

        editor.$blockScrolling = Infinity

        setting = null
        getting = null
        @observe \code, (val) ~>
            return if getting
            setting := yes
            editor.set-value(val or '')
            editor.clear-selection!
            setting := no

        editor.on \change, ~>
            getting := true
            # remove trailing whitespaces
            content = editor.get-value!.replace /[^\S\r\n]+$/gm, ''
            @set \code, content
            getting := false

    data: ->
        theme: \light
        mode: \javascript
