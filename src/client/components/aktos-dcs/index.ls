require! 'dcs/browser': {SocketIOBrowser}

require! 'prelude-ls': {initial, drop, join}
curr-url = ->
    url = String window.location .split '#' .0
    arr = url.split "/"
    do
        host-port: arr.0 + "//" + arr.2
        host: "#{arr.0}//#{arr.2.split ':' .0}"
        port: parse-int "#{(arr.2.split ':' .1) or 80}"

Ractive.components['aktos-dcs'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        url = curr-url!
        new SocketIOBrowser {host: url.host, port: url.port}
