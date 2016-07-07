# for debugging purposes
st = new Date! .get-time!
export debug-log = (...print) ->
    console.log (new Date! .get-time! - st) + "ms : " + print.join(' ')
