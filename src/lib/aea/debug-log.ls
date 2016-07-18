# for debugging purposes
st = new Date! .get-time!
export debug-log = (...print) ->
    console.log (new Date! .get-time! - st) + "ms : " + print.join(' ')

function align-left width, inp
    x = (inp + " " * width).slice 0, width

export get-logger = (src) ->
    (...x) -> debug-log.call this, (align-left 15, "#{src}") + ":" + x.join('')
