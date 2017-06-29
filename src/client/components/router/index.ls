require! page
require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split}

Ractive.components['anchor'] = Ractive.extend do
    template: '<a data-id="{{yield}}"></a>'
    isolated: yes

scroll-to = (anchor) ->
    offset = $ "a[data-id='#{anchor}']" .offset!
    if offset
        $ 'html, body' .animate do
            scroll-top: offset.top - 55px
            , 500ms

make-hash = (scene, anchor) ->
    '/' + scene + if anchor? then '#' + anchor else ''

get-window-hash = ->
    hash = window.location.hash
        .replace '%23', '#'
    set-window-hash hash
    hash or '#/'

set-window-hash = (hash) ->
    window.location.hash = hash

parse-link = (link) ->
    [scene, anchor] = ['/', '']
    switch take 2, link
    | '#/' => [scene, anchor] = drop 2, link .split '#'
    | '##' => [scene, anchor] = [undefined, (drop 2, link)]
    |_     => [scene, anchor] = [undefined, (drop 1, link)]

    return do
        scene: scene
        anchor: anchor


Ractive.components["a"] = Ractive.extend do
    template: '
        <a class="{{class}}"
                style="{{style}}"
                on-click="click"
                {{#if @.get("data-id")}}data-id=\'{{@.get("data-id")}}\' {{/if}}>
            {{yield}}
        </a>'
    isolated: no
    components: {a: false}
    onrender: ->
        onclick = @get \onclick
        newtab = @get \newtab
        href = @get \href

        @on do
            click: (event) ->
                if newtab
                    window.open href
                    return

                if onclick
                    #console.log "evaluating onclick: #{onclick}"
                    eval onclick
                    return

                if href?
                    curr = parse-link get-window-hash!
                    link = parse-link href
                    if link
                        scene = if link.scene => link.scene else curr.scene
                        anchor = link.anchor
                        set-window-hash make-hash scene, anchor
                        # scrolling will be performed by hash observer (in the router)
                        # but, if hash is not changed but user clicked again, we should
                        # scroll to link anyway
                        scroll-to anchor

                else
                    console.log "can not determine action..."
                    debugger


Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    oncomplete: ->
        do handle-hash = ~>
            curr = parse-link get-window-hash!
            if curr
                @set \curr, curr.scene
                @set \anchor, curr.anchor
                sleep 50ms, -> scroll-to curr.anchor
                console.log """hash changed: scene: #{curr.scene}, anchor: #{curr.anchor}"""

        $ window .on \hashchange, ->
            console.log "this is hashchange run: #{window.location.hash}"
            handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: '
        <div name="{{name}}"
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
            console.log "scene says: current is: ", curr
            this-page = @get \name
            default-page = @get 'default'
            if this-page is default-page
                #console.log "#{@get 'name'} is the default scene. curr is: #{curr}"
                if curr is ''
                    @set \visible, yes
                    sleep 5ms, ~>
                        @set \renderedBefore, yes
                        console.log "rendering content of #{this-page} (because this is default)"
                    return

            if curr is this-page
                #console.log "#{@get 'name'} scene is selected"
                @set \visible, yes
                sleep 5ms, ~>
                    @set \renderedBefore, yes
                    console.log "rendering content of #{this-page} (because this is selected)"
                return

            @set \visible, no

    data: ->
        rendered-before: no
