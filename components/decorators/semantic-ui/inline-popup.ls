Ractive.decorators.['inline-popup'] = (node, opts={}) ->
    popup = $ node .popup do
        inline: yes
        on: \click
        last-resort: on
        position: opts.position
    return do
        teardown: ->
            $ node .popup \destroy


/* Example:

    .ui.label(class-green="step.curr.name" as-inline-popup) {{step.curr.name || "Başlamadı."}}
    .ui.fluid.popup.top.transition.hidden
        h1.ui.top.attached.block.header Geçilen Aşamalar
        .ui.attached.segment
            table.ui.description.table
                thead
                    tr
                        th Tarih
                        th Aşama
                        th Çalışan
                tbody
                    +each('step.history as prev')
                        tr
                            td(style="white-space: nowrap") {{unixToReadable(prev.timestamp)}}
                            td {{prev.stationName || prev.step.state}}
                            td {{prev.workerName || prev.step.user}}
    */

/* Example 2

    Positioning:

        .ui.label(as-inline-popup="{position: 'right center'}") Export
