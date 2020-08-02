require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split, find}
require! 'actors':  {RactiveActor}

basename = (.split(/[\\/]/).pop!) # https://stackoverflow.com/questions/3820381#comment29942319_15270931

get-offset = ->
    $ 'body' .scrollTop!

scroll-to = (anchor) ->
    offset = $ "span[data-id='#{anchor}']" .offset!
    if offset
        $ 'html, body' .animate do
            scroll-top: (offset?.top or 0) - (window.top-offset or 0)
            , 200ms

make-link = (scene, anchor) ->
    curr = parse-link get-window-hash!
    scene-part = if scene? => that else curr.scene

    scene-part = if scene-part
        '#/' + that
    else
        '#'

    anchor-part = if anchor?
        '#' + that
    else
        ''

    link = scene-part + anchor-part
    #console.log "Making link from scene: #{scene}, anchor: #{anchor} => #{link} (curr.scene: #{curr.scene})"
    return link

get-window-hash = ->
    hash = window.location.hash
    _hash = hash.replace '%23', '#'
    if hash isnt _hash
        hash = _hash
        set-window-hash hash, silent=yes
    hash or '#/'

hash-listener = ->

_scroll-top = null
set-window-hash = (hash, silent) ->
    #console.log "setting window hash to: #{hash}, curr is: #{window.location.hash}"
    if history.pushState
        history.pushState(null, null, hash)
    else
        window.location.hash = hash

    unless silent
        hash-listener hash

parse-link = (link) ->
    if link.match /http[s]?:\/\//
        return {external: yes}

    [scene, anchor] = ['/', '']
    switch take 2, link
    | '#/' => [scene, anchor] = drop 2, link .split '#'
    | '##' => [scene, anchor] = ['', (drop 2, link)]
    |_     => [scene, anchor] = [undefined, (drop 1, link)]

    #console.log "parsing link: #{link} -> scene: #{scene}, anchor: #{anchor}"
    return do
        scene: scene
        anchor: anchor


Ractive.components['a'] = Ractive.extend do
    template: require('./a.html')
    isolated: no
    components: {a: false}
    data: ->
        title: ''
        tooltip: ''
        href: null
    onrender: ->
        @on do
            click: (ctx) ->
                href = @get \href
                if @get \newtab
                    return window.open href

                if @get \onclick
                    #console.log "evaluating onclick: #{that}"
                    return eval that

                if href?
                    link = if @get('download') then {+download} else parse-link href
                    if link.download
                        filename = basename(href)
                        link = document.createElement("a")
                        link.setAttribute("target","_blank")
                        link.setAttribute("href", href)
                        link.setAttribute("download",filename)
                        document.body.appendChild(link)
                        link.click()
                        document.body.removeChild(link)
                    else if link.external
                        if @get \curr-window
                            window.open href, "_self"
                        else
                            # external links are opened in a new tab by default
                            window.open href
                        return
                    else if link
                        generated-link = make-link link.scene, link.anchor
                        #console.log "setting window hash by '<a>' to ", generated-link

                        # WORKAROUND: jquery.scrollTop! is somehow
                        # set to 0 when `set-window-hash` is called.
                        _scroll-top := $ document .scrollTop!
                        #console.log "...scroll top: ", _scroll-top
                        set-window-hash generated-link
                    else
                        console.error "there seems a no valid link:", link
                        debugger


Ractive.components['anchor'] = Ractive.extend do
    template: require('./anchor.html')
    isolated: yes


Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    oncomplete: ->
        offset = (@get \offset) or 0
        @set \@global.topOffset, offset
        change = {}
        actor = new RactiveActor this, 'router'
            ..subscribe 'app.router.**'
            ..on \request-update, (topic, respond) ~>
                console.log "router received request update: ", topic
                respond change
        prev = {}
        active-scene = null

        handle-hash = (opts={}) ~>
            curr = parse-link get-window-hash!
            if curr
                if (curr.scene isnt prev.scene) or opts.force
                    # note the current scroll position
                    page = prev?.scene or \default
                    change.scene = curr.scene
                    screen-top = _scroll-top or get-offset!
                    _scroll-top := null

                    #console.log "Saving current position as #{screen-top} for page #{page}"
                    if active-scene
                        #console.log "setting active scene's (#{that.get 'name' or 'default'}) offset to: #{screen-top}"
                        that.set \lastScroll, screen-top
                        that.set \visible, no

                    #console.log "curr scene is: ", curr.scene
                    active-scene := null
                    for @get \@shared.scenes
                        this-page = (..get \name) or \default
                        is-default = ..get 'default'

                        if (curr.scene is '' and is-default) or (curr.scene is this-page)
                            # check the permissions
                            if @able(..get 'permissions') or ..get \public
                                #console.log "Setting #{this-page} as visible for request #{curr.scene}"
                                active-scene := ..
                            else
                                console.warn "We don't have permissions to see the scene, displaying an UNAUTHORIZED scene"
                                active-scene := find ((p) -> (p.get 'name') is 'UNAUTHORIZED'), @get \@shared.scenes
                            break

                    unless active-scene
                        # display a 404 scene
                        if find ((p) -> (p.get 'name') is 'NOTFOUND'), @get \@shared.scenes
                            active-scene := that
                            #console.log "Found 404 page, displaying it..."
                        else
                            console.error "Neither requested page, nor a 404 scene is found."

                    if active-scene
                        that
                            ..set \hidden, yes
                            ..set \visible, yes
                            ..set \renderedBefore, yes
                            unless opts.noscroll
                                $ document .scrollTop ..get \lastScroll
                            ..set \hidden, no

                if curr.anchor isnt prev.anchor
                    change.anchor = curr.anchor

                unless opts.noscroll
                    sleep 50ms, -> scroll-to curr.anchor

                actor.send 'app.router.changes', {change}
                @set \@shared.router, change

                # save curr scene as previous
                prev <<< curr

        @observe \@global.session.permissions, ->
            console.log "permissions changed, re-handling the hash"
            handle-hash {force: yes, noscroll: yes}

        hash-listener := (hash) ->
            #console.log "fired hash listener! hash is: #{hash}"
            handle-hash!

        $ window .on \hashchange, ->
            console.log "this is hashchange run: #{window.location.hash}"
            handle-hash!

        # on app-load
        handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: require('./scene.html')
    isolated: no
    oninit: ->
        if @get \render
            @set \renderedBefore, yes

        if (@get \name) in <[ NOTFOUND UNAUTHORIZED ]>
            @set \public, yes

        @observe \visible, (curr, prev) ->
            if not prev and curr
                @fire \enter
            else if prev and not curr
                @fire \exit

        @push \@shared.scenes, this

    data: ->
        offset: null
        name: ''
        hidden: no
        visible: no
        renderedBefore: no
        loggedin: yes
        permissions: ""
        lastScroll: 0
        public: no
