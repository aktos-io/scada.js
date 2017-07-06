require! 'aea': {sleep}

Ractive.components['drawing-area'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    onrender: ->
        <~ sleep 10ms
        drawing-area = $ @find \.scada-drawing-area
        drawing-container = $ @find \.drawing-area-container

        parent = drawing-area.parent!
        drawing-area.css "margin-left", "-"+(parent.css "padding-left")
        drawing-area.css "margin-top", "-"+(parent.css "padding-top")

        # set widths
        drawing-area.css "width", parent.css "width"
        drawing-container.css \width, (parent.css \width)

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


    data: ->
        desktop: yes


Ractive.components['widget'] = Ractive.extend do
    template: '
        <div class="widget"
            style="
                {{#if x}}left: {{x}};{{/if}}
                {{#if y}}top: {{y}};{{/if}}
                {{#if width}}width: {{width}};{{/if}}
                {{#if height}}height: {{height}};{{/if}}
                "
        >
            {{yield}}
        </div>
        '
    isolated: no
    data: ->
        x: 0
        y: 0
