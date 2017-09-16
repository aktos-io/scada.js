require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split}
require! 'dcs/browser':  {RactiveActor}

Ractive.components['anchor'] = Ractive.extend do
    template: '<a data-id="{{yield}}"></a>'
    isolated: yes

scroll-to = (anchor) ->
    offset = $ "a[data-id='#{anchor}']" .offset!
    if offset
        $ 'html, body' .animate do
            scroll-top: offset.top - 55px
            , 500ms

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
        .replace '%23', '#'
    set-window-hash hash
    hash or '#/'

set-window-hash = (hash) ->
    #console.log "setting window hash to: #{hash}, curr is: #{window.location.hash}"
    window.location.hash = hash

parse-link = (link) ->
    [scene, anchor] = ['/', '']
    switch take 2, link
    | '#/' => [scene, anchor] = drop 2, link .split '#'
    | '##' => [scene, anchor] = ['', (drop 2, link)]
    |_     => [scene, anchor] = [undefined, (drop 1, link)]

    #console.log "parsing link: #{link} -> scene: #{scene}, anchor: #{anchor}"
    return do
        scene: scene
        anchor: anchor


Ractive.components["a"] = Ractive.extend do
    template: '''
        <a class="{{class}}"
            style="
                {{#href}}cursor: pointer;{{/if}}
                {{style}}
                "
            on-click="_click"
            data-id="{{~['data-id']}}"
            title="{{href}}"
            >
            {{yield}}
        </a>
        '''
    isolated: no
    components: {a: false}
    onrender: ->
        onclick = @get \onclick
        newtab = @get \newtab

        @on do
            _click: (ctx) ->
                href = @get \href
                if newtab
                    return window.open href

                if onclick
                    #console.log "evaluating onclick: #{onclick}"
                    return eval onclick

                if href?
                    link = parse-link href
                    if link
                        generated-link = make-link link.scene, link.anchor
                        #console.log "<a href=", link, "generated link: #{generated-link}"
                        set-window-hash generated-link
                        # scrolling will be performed by hash observer (in the router)
                        # but, if hash is not changed but user clicked again, we should
                        # scroll to link anyway
                        scroll-to link.anchor
                    else
                        console.error "there seems a no valid link:", link
                        debugger

                if not ctx.from-my-click
                    const c = ctx.getParent yes
                    c.refire = yes
                    c.a-has-fired = yes
                    @fire \click, c

            click: (ctx) ->
                const c = ctx.getParent yes
                c.refire = yes
                c.from-my-click = yes
                @fire \_click, c





Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    oncomplete: ->
        actor = new RactiveActor this, 'router'

        prev =
            scene: undefined
            anchor: undefined

        do handle-hash = ~>
            curr = parse-link get-window-hash!
            if curr
                @set \curr, curr.scene
                @set \anchor, curr.anchor
                sleep 50ms, -> scroll-to curr.anchor
                #console.log """hash changed: scene: #{curr.scene}, anchor: #{curr.anchor}"""

                change = {}
                if curr.scene isnt prev.scene
                    change.scene = curr.scene
                if curr.anchor isnt prev.anchor
                    change.anchor = curr.anchor
                actor.send 'my.router.changes', change
                prev <<< curr

        $ window .on \hashchange, ->
            #console.log "this is hashchange run: #{window.location.hash}"
            handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: '
        <div name="{{name}}"
            class="{{class}}"
            style="
                {{#unless visible}} display: none; {{/unless}}
                margin: 0;
                padding: 0;
                border: 0;
                "
            > {{#if renderedBefore}}{{>content}}{{/if}}
        </div>'

    isolated: no
    oninit: ->
        if @get \render
            @set \renderedBefore, yes

        @observe \curr, (curr) ->
            #console.log "scene says: current is: ", curr
            this-page = @get \name
            default-page = @get 'default'
            if default-page
                #console.log "#{@get 'name'} is the default scene. curr is: #{curr}"
                if curr is ''
                    @set \visible, yes
                    sleep 5ms, ~>
                        @set \renderedBefore, yes
                        #console.log "rendering content of #{this-page} (because this is default)"
                    return

            if curr is this-page
                #console.log "#{@get 'name'} scene is selected"
                @set \visible, yes
                sleep 5ms, ~>
                    @set \renderedBefore, yes
                    #console.log "rendering content of #{this-page} (because this is selected)"
                return

            @set \visible, no

    data: ->
        rendered-before: no
