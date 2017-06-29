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
            scroll-top: offset.top - 45px
            , 500ms

make-hash = (scene, anchor) ->
    '/' + scene + if anchor? then '#' + anchor else ''

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
                on-click="navigate"
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


Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    onrender: ->
        do handle-hash = ~>
            curr = parse-link window.location.hash
            if curr
                @set \curr, curr.scene
                @set \anchor, curr.anchor
                sleep 50ms, -> scroll-to curr.anchor
                console.log """listening hash. current scene:
                    #{curr.scene}, anchor: #{curr.anchor}"""

        $ window .on \hashchange, -> handle-hash!


Ractive.components['scene'] = Ractive.extend do
    template: ->
        debug = no
        if debug
            '<div name="{{name}}"
                style="
                    {{#unless isSelected(curr)}} border: 5px dashed red {{/unless}};
                    margin: 0;
                    padding: 0;
                    border: 0;
                    "
                > {{>content}}
            </div>'
        else
            '<div name="{{name}}"
                style="
                    {{#unless isSelected(curr)}} display: none; {{/unless}}
                    margin: 0;
                    padding: 0;
                    border: 0;
                    "
                > {{>content}}
            </div>'

    isolated: no
    data: ->
        is-selected: (url) ~>
            #console.log "PAGE: #{@get 'name'} url: #{url}"
            this-page = @get \name
            default-page = @get 'default'
            curr = @get \curr

            #console.log "#{@get 'name'} says current scene is:", curr
            if this-page is default-page
                console.log "#{@get 'name'} is the default scene. curr is: #{curr}"
                if curr is '' or curr is undefined
                    @set \visible, yes
                    return yes

            if curr is this-page
                #console.log "#{@get 'name'} scene is selected"
                @set \visible, yes
                return yes

            @set \visible, no
            return no
