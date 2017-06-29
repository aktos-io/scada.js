require! page
require! 'aea': {sleep}
require! 'prelude-ls': {take, drop, split}

Ractive.components['anchor'] = Ractive.extend do
    template: '<a data-id="{{yield}}"></a>'
    isolated: yes

scroll-to = (anchor) ->
    offset = $ "span[data-id='#{anchor}']" .offset!
    if offset
        $ 'html, body' .animate do
            scroll-top: offset.top - 45px
            , 500ms


Ractive.components["a"] = Ractive.extend do
    template: '
        <span class="aa {{class}}"
            style="{{style}}"
            on-click="navigate"
            {{#if @.get("data-id")}}data-id=\'{{@.get("data-id")}}\' {{/if}}>
        {{yield}}
        </span>'
    isolated: no
    onrender: ->
        onclick = @get \onclick
        newtab = @get \newtab
        href = @get \href
        @on do
            navigate: (event) ->
                if href?
                    if (take 2, href) is '#/'
                        [_page, _anchor] = drop 1, href |> split '#'
                        console.log "this is a page change request, page: #{_page}, anchor: #{_anchor} "
                    else
                        _anchor = drop 1, href
                        scroll-to _anchor
                        console.log "this is just a normal anchor to: #{href}"

                    if newtab
                        window.open href

                else if onclick
                    console.log "evaluating onclick: #{onclick}"
                    eval onclick
                else
                    console.log "can not determine action..."
                    debugger

        console.log "a is rendered: href is #{@get 'href'}"

Ractive.components['router'] = Ractive.extend do
    template: ''
    isolated: yes
    onrender: ->
        __ = @


        page '*', (ctx, next) ->
            _old = __.get \curr
            _new = ctx.path
            if _new isnt _old
                __.set \curr, _new
            <- sleep 20ms
            scroll-to ctx.hash if ctx.hash

        page!

        /*
        @set \curr, '#/' if (@get \curr) is void

        do function hashchange
            hash = window.location.hash
            hash = '/' unless hash
            __.set \curr, hash

        $ window .on \hashchange, -> hashchange!
        */

    data: ->
        curr: '/'
        root: 'showcase.html'


Ractive.components['page'] = Ractive.extend do
    template: RACTIVE_PREPARSE('page.pug')
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
