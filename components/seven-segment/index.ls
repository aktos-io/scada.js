defs =
    "0": {+a, +b, +c, +d, +e, +f}
    "1": {+b, +c}
    "2": {+a, +b, +g, +e, +d}
    "3": {+a, +b, +c, +g, +d}
    "4": {+f, +g, +b, +c}
    "5": {+a, +f, +g, +c, +d}
    "6": {+a, +f, +g, +c, +d, +e}
    "7": {+a, +b, +c}
    "8": {+a, +b, +c, +d, +e, +f, +g}
    "9": {+a, +b, +c, +d, +f, +g}
    " ": {}
    "C": {+a, +f, +e, +d}

get-char-bits = (text) ->
    sstext = []
    for i til text?.length
        char = text[i]
        if char is \. then continue
        if defs[char]
            x = {}
            x.dot = try
                on if text[i+1] is '.'
            catch
                off
            x.char = defs[char]
            sstext.push x
    sstext

Ractive.components['seven-segment'] = Ractive.extend do
    template: require('./index.pug')
    onrender: ->
        @observe \value, (text) ->
            if text?
                @set \sstext, get-char-bits "#{text}"
            else
                @set \sstext, get-char-bits "---"

    data: ->
        value: '1234567.890 C'
