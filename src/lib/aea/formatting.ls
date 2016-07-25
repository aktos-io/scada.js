export unix-to-readable = (unix) ->
    display = moment (new Date unix) .format 'DD.MM.YYYY HH:mm'
    #console.log "UNIX_TO_READABLE: ", display
    display

export readable-to-unix = (display) ->
    unix = moment(display, 'DD.MM.YYYY HH:mm').unix! * 1000ms
