require! 'dcs/browser': {SocketIOBrowser}

require! 'prelude-ls': {initial, drop, join, split}
curr-url = ->
    [full-addr, hash] = split '#', String window.location
    [protocol, addr-with-path] = split '://', full-addr
    [host, ...path-arr] = split '/', addr-with-path
    path = join '/', path-arr

    if path.0 is '/'
        console.error "Check address. Path part can not be started with double slashes."

    return do
        host: host
        host-url: "#{protocol}://#{host}"
        path: "/#{path}"
        port: (split ':', host .1) or (if protocol is 'https' then 443 else 80)
        hash: hash
        protocol: protocol
        root: document.location.hostname

Ractive.components['aktos-dcs'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        url = curr-url!
        @transport = new SocketIOBrowser do
            address: url.host-url
            path: url.path

        @set \transport-id, @transport.id
