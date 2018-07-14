require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split, find}
require! 'actors':  {RactiveActor}


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


Ractive.components.a = Ractive.extend do
    template: '''
        <a class="{{class}}"
            style="
                {{#href}}cursor: pointer;{{/}}
                {{style}}
                "
            on-click="click"
            bind-data-id
            {{#if tooltip}}title="{{tooltip}}"{{/if}}
            >
            {{yield}}
        </a>
        '''
    isolated: no
    components: {a: false}
    data: ->
        tooltip: null
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
                    link = parse-link href
                    if link.external
                        if @get \curr-window
                            window.open href, "_self"
                        else
                            # external links are opened in a new tab by default
                            window.open href
                        return
                    else if link
                        generated-link = make-link link.scene, link.anchor
                        #console.log "setting window hash by '<a>' to ", generated-link
                        set-window-hash generated-link
                    else
                        console.error "there seems a no valid link:", link
                        debugger



Ractive.components['anchor'] = Ractive.extend do
    template: '<span data-id="{{yield}}"></span>'
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

        do handle-hash = ~>
            curr = parse-link get-window-hash!
            if curr
                if curr.scene isnt prev.scene
                    # note the current scroll position
                    page = prev?.scene or \default
                    change.scene = curr.scene
                    screen-top = get-offset!
                    #console.log "Saving current position as #{screen-top} for page #{page}"
                    if active-scene
                        console.log "setting active scene's (#{that.get 'name' or 'default'}) offset to: #{screen-top}"
                        that.set \lastScroll, screen-top
                        that.set \visible, no

                    console.log "curr scene is: ", curr.scene
                    active-scene := null
                    for @get \@shared.scenes
                        this-page = (..get \name) or \default
                        is-default = ..get 'default'
                        if (curr.scene is '' and is-default) or (curr.scene is this-page)
                            console.log "Setting #{this-page} as visible for request #{curr.scene}"
                            ..set \hidden, yes
                            ..set \visible, yes
                            active-scene := ..
                            ..set \renderedBefore, yes
                            #console.log  "scroll to last position: #{..get 'lastScroll'}"
                            $ document .scrollTop ..get \lastScroll
                            ..set \hidden, no

                    unless active-scene
                        # display a 404 scene
                        if that = find ((p) -> (p.get 'name') is 'NOTFOUND'), @get \@shared.scenes
                            console.log "Found 404 page, displaying it..."
                            active-scene := that
                                ..set \hidden, yes
                                ..set \visible, yes
                                ..set \renderedBefore, yes
                                ..set \hidden, no
                        else
                            console.error "Neither requested page, nor a 404 scene is found."

                if curr.anchor isnt prev.anchor
                    change.anchor = curr.anchor


                sleep 50ms, -> scroll-to curr.anchor

                actor.send 'app.router.changes', {change}
                @set \@shared.router, change

                # save curr scene as previous
                prev <<< curr

        hash-listener := (hash) ->
            #console.log "fired hash listener! hash is: #{hash}"
            handle-hash!

        $ window .on \hashchange, ->
            #console.log "this is hashchange run: #{window.location.hash}"
            handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: '
        <div name="{{name}}"
            class="{{class}}"
            style="
                {{#unless visible}} display: none; {{/unless}}
                {{#if hidden}}visibility: hidden; {{/if}}
                margin: 0;
                padding: 0;
                padding-top: {{@global.topOffset}}px;
                border: 0;
                "
            >
            {{#unless public}}
                {{#if @global.session.user === "public" || @global.session.user === "" }}
                    <div class="ui red message fluid" style="
                            position: fixed; top: 0; left: 0; z-index: 999999999;
                            width: 100%; height: 100%; padding-left: 2em; padding-right: 2em">
                        <h2 class="ui header block red">Login required</h2>
                        <login />
                    </div>
                {{/if}}
            {{/unless}}
            {{#if able(permissions) || public}}
                {{#if renderedBefore}}
                    {{>content}}
                {{/if}}
            {{else}}
                <h1>Unauthorized.</h1>
                {{JSON.stringify(@global.session.permissions)}}
            {{/if}}
        </div>'

    isolated: no
    oninit: ->
        if @get \render
            @set \renderedBefore, yes

        if @get \default
            #@set \visible, yes
            null

        if (@get \name) in <[ NOTFOUND UNAUTHORIZED ]>
            @set \public, yes

        @push \@shared.scenes, this

    data: ->
        name: ''
        hidden: no
        visible: no
        renderedBefore: no
        loggedin: yes
        permissions: "**"
        lastScroll: 0
        public: no
        code: 200
