require! 'aea': {sleep}

Ractive.components['drawing-area'] = Ractive.extend do
    template: require('./drawing-area.pug')
    isolated: no
    onrender: ->
        <~ sleep 10ms
        drawing-area = $ @find \.scada-drawing-area
        drawing-container = $ @find \.drawing-area-container

        parent = drawing-area.parent!

        if @get \ignore-parent-padding
            # overrides (ignores) parent container's padding
            drawing-area.css "margin-left", "-"+(parent.css "padding-left")
            drawing-area.css "margin-top", "-"+(parent.css "padding-top")

            # set widths
            drawing-area.css "width", parent.css "width"
            drawing-container.css \width, (parent.css \width)

        if @get \auto-height
            max-height = 0
            children = drawing-container.children!
            for c in children
                height = $ c .height!
                offset = $ c .offset!
                total = offset.top + height
                max-height = total if total > max-height
                #console.log "childrens: #{height}, #{offset.top}"

            max-height -= drawing-area.offset! .top
            my-padding = 40px
            drawing-container.css \height, (max-height)
            drawing-area.css \height, (max-height + my-padding)

        if @get \height
            drawing-area.css \height, that
