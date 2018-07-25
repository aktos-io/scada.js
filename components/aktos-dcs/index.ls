require! 'dcs/services/dcs-proxy/socket-io/browser': {DcsSocketIOBrowser}
require! 'actors/browser-storage': {BrowserStorage}
require! 'prelude-ls': {initial, drop, join, split}
require! 'dcs/src/topic-match': {topic-match}

# Permission calculation mechanism
Ractive.defaults.able = (permission) ->
    permissions = try
        @get \@global.session.permissions
    catch
        null
    permission `topic-match` permissions

Ractive.defaults.hasRoute = (route) ->
    routes = try
        @get \@global.session.routes
    catch
        null
    routes `topic-match` route

Ractive.defaults.unable = (...args) ->
    not Ractive.defaults.able.apply this, args


curr-url = (_url)->
    if _url => _url = "#{_url}/"
    [full-addr, hash] = split '#', (_url or String window.location)
    [protocol, addr-with-path] = split '://', full-addr
    [host, ...path-arr] = split '/', addr-with-path
    path = join '/', path-arr

    if path.0 is '/'
        console.error "Check address. Path part can not be started with double slashes."

    url =
        host: host
        host-url: "#{protocol}://#{host}"
        path: "/#{path}"
        port: (split ':', host .1) or (if protocol is 'https' then 443 else 80)
        hash: hash
        protocol: protocol
        root: document.location.hostname
        app-id: addr-with-path
    return url

Ractive.components['aktos-dcs'] = Ractive.extend do
    /*
    Responsible for creating a realtime server connection and
    keeping global `window.session` variable in sync
    */
    template: ''
    isolated: yes
    oninit: ->
        url = curr-url @get \url
        if url.protocol is \file
            url.host-url = "http://localhost:4008"
            url.path = "/"

        proxy = new DcsSocketIOBrowser do
            address: url.host-url
            path: url.path
            db: new BrowserStorage "#{url.app-id}dcs"

        # global session information
        empty-session =
            user: ''
            password: ''
            loggedin: no
            token: null
            permissions: {}

        # empty session on startup
        @set \@global.session, empty-session

        # when connected, set global session object for ractive
        proxy.on \logged-in, (session) ~>
            proxy.log.log "...seems logged in."
            @set \@global.session, session

        proxy.once \logged-in, (session) ~>
            console.warn "Logged in for the first time."
            @fire 'live'

        proxy.on \logged-out, ~>
            proxy.log.log "seems logged out."
            @set \@global.session, empty-session

        proxy.on \kicked-out, ~>
            proxy.log.log "seems kicked out."
            @set \@global.session, empty-session
