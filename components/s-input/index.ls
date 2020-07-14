``
function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}

//alert( rgbToHex(0, 51, 255) ); // "#0033ff"

function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

//alert( hexToRgb("#0033ff").g ); // 51;
``

require! 'prelude-ls': {map}

Ractive.components['s-input'] = Ractive.extend do
    template: require('./index.pug')
    onrender: ->
        if @get("type") is \color
            inner = null
            outer = null
            outer = @observe \value, (val) ->
                return unless val
                [r, g, b] = val.components |> map (* 255 |> parse-int)
                hex-color = rgbToHex r, g, b
                inner?.silence!
                @set \_value, hex-color
                inner?.resume!

            unless @get \readonly
                inner = @observe \_value, (val) ->
                    return unless val
                    if (@get \variant) is \Color
                        rgb = hexToRgb val
                        if @get \value
                            outer?silence!
                            that
                                ..red = rgb.r / 255
                                ..green = rgb.green / 255
                                ..blue = rgb.blue / 255
                            outer?resume!

    data: ->
        readonly: no
        value: undefined
        type: \text
        _value: undefined
        variant: \Color
