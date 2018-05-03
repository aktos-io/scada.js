require! 'dcs/browser': {DcsSocketIOBrowser}
require! 'actors/browser-storage': {BrowserStorage}
require! 'prelude-ls': {initial, drop, join, split}
require! 'dcs/browser': {topic-match}

# Permission calculation mechanism
Ractive.defaults.canSee = (topic) ->
    permissions = try
        @get \@global.session.permissions
    catch
        null
    #console.log "Cansee: known permissions: ", permissions
    if permissions
        for perm in (permissions.ro or []) ++ (permissions.rw or [])
            if topic `topic-match` perm
                return yes
    return no

Ractive.defaults.canWrite = (topic) ->
    permissions = try
        @get \@global.session.permissions
    catch
        null
    #console.log "Canwrite: known permissions: ", permissions
    if permissions
        for perm in (permissions.rw or [])
            if topic `topic-match` perm
                return yes
    return no

Ractive.defaults.cannotSee = (...args) ->
    not Ractive.defaults.canSee.apply this, args

Ractive.defaults.cannotWrite = (...args) ->
    not Ractive.defaults.canWrite.apply this, args


curr-url = ->
    [full-addr, hash] = split '#', String window.location
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
        url = curr-url!
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

        proxy.on \logged-out, ~>
            proxy.log.log "seems logged out."
            @set \@global.session, empty-session

        proxy.on \kicked-out, ~>
            proxy.log.log "seems kicked out."
            @set \@global.session, empty-session
