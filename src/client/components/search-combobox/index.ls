component-name = "search-combobox"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        button = $ @find '.face'
        container = $ @find \.selection-list
        searchbox = $ @find \.searchbox

        get-data = ->
            __.get(\data) or []


        button.on \click, ->
            __.set \slVisible, not __.get \slVisible


        # detect click event outside of selection-list
        $ document .click (e) ->
            if !$(e.target).closest(container).length and not $(e.target).is(button)
                unless $ e.target .is \input
                    __.set \slVisible, false
                    __.set \searchedText, ''

        do filter-selection = (new-val) ->
            orig-data = get-data!
            unless new-val
                filtered = orig-data
            else
                map-to-ascii = (x) ->
                    x = x.to-lower-case!
                    m = 'çalışöğünÇALIŞÖĞÜN': "calisoguncalisogun"

                    for source, target of m
                        for i of source
                            #console.log "i: #{i}, source[i]: #{source[i]}: #{target[i]}"

                            x = x.replace (new RegExp source[i], "gi"), target[i]
                    x
                filtered = [.. for orig-data when map-to-ascii(..name).index-of(map-to-ascii new-val) > -1 ]

            __.set \filtered, filtered

        @observe \searchedText, filter-selection

        @on do
            select: (val) ->
                selected-text = [..name for get-data! when ..id is val].0 or __.get \selectedText
                __.set \selected, val
                __.set \selectedText, selected-text
                __.set \slVisible, false
                __.set \searchedText, ''


        selected = @get \selected
        if selected
            @fire \select, selected

        @observe \selected, (val) ->

            unless isNaN parse-int val
                val = parse-int val

            console.log "selected changed!", val
            __.fire \select, val

    data: ->
        sl-visible: no
        selected-text: "Seçim Yapılmadı"
