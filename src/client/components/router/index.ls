require! page
require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split}

Ractive.components['anchor'] = Ractive.extend do
    template: '<aa data-id="{{yield}}"></aa>'
    isolated: yes

scroll-to = (anchor) ->
    offset = $ "a[data-id='#{anchor}']" .offset!
    if offset
        $ 'html, body' .animate do
            scroll-top: offset.top - 45px
            , 500ms

make-hash = (scene, anchor) ->
    '/' + scene + if anchor? then '#' + anchor else ''

parse-link = (link) ->
    [scene, anchor] = ['/', '']
    switch take 2, link
    | '#/' => [scene, anchor] = drop 2, link .split '#'
    | '##' => [scene, anchor] = [undefined, (drop 2, link)]
    |_ => return console.warn "can not determine the prefix. link is: #{link}"

    return do
        scene: scene
        anchor: anchor


Ractive.components["aa"] = Ractive.extend do
    template: '
        <a class="aa {{class}}"
                style="{{style}}"
                on-click="navigate"
                {{#if @.get("data-id")}}data-id=\'{{@.get("data-id")}}\' {{/if}}>
            {{yield}}
        </a>'

    isolated: no
    onrender: ->
        onclick = @get \onclick
        newtab = @get \newtab
        href = @get \href
        @on do
            navigate: (event) ->
                if newtab
                    window.open href
                    return

                if onclick
                    #console.log "evaluating onclick: #{onclick}"
                    eval onclick
                    return

                if href?
                    curr = parse-link window.location.hash
                    link = parse-link href
                    if link
                        scene = if link.scene => link.scene else curr.scene
                        anchor = link.anchor
                        window.location.hash = make-hash scene, anchor
                        # scrolling will be performed by hash observer (in the router)
                else
                    console.log "can not determine action..."
                    debugger

        console.log "a is rendered: href is #{@get 'href'}"

Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    onrender: ->
        do handle-hash = ~>
            curr = parse-link window.location.hash
            if curr
                @set \curr, curr.scene
                @set \scene, curr.scene
                @set \anchor, curr.anchor
                scroll-to curr.anchor 
                console.log """listening hash. current scene:
                    #{curr.scene}, anchor: #{curr.anchor}"""

        $ window .on \hashchange, -> handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: RACTIVE_PREPARSE('scene.pug')
    isolated: no
    data: ->
        is-selected: (url) ->
            __ = @
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            this-page = @get \name
            landing-page = @get 'landing-page'
            if this-page is '/' or landing-page
                if url in ['', void, null, '/']
                    @set \visible, true
                    return true

            first-part = url.substring 0, (this-page.length + 1)
            show-page = first-part is ('#' + this-page)

            @set \visible, show-page
            return show-page

        visible: no
        curr: ''
