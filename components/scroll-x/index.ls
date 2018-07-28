# creates a container that fits the parent width and scroll
require! 'aea': {sleep}
require! 'dcs/src/filters': {FpsExec}

Ractive.components['scroll-x'] = Ractive.extend do
    template: '''
        <div class="scroll-x-outer">
            <div class="scroll-x-container">
                {{yield}}
            </div>
        </div>
    '''
    isolated: no
    onrender: ->
        fps = new FpsExec 5fps

        outer = $ @find \.scroll-x-outer
        container = $ @find \.scroll-x-container
        set-container-height = ~>
            height = container.height!

            if height is 0
                # component is inside a "display: none" div
                # calculate its actual height
                copied = container.clone!
                    .attr \id, false
                    .css do
                        visibility:"hidden"
                        display:"block",
                        position:"absolute"

                $ \body .append copied
                height = copied.height!
                copied.remove!
            outer.css \height, height

        # set initial height
        set-container-height!

        # watch for DOM changes
        container.bind 'DOMSubtreeModified', (e) ~>
            if e.target.innerHTML.length > 0
                #console.log "changed inner html"
                # DOM may change too fast, limit re-calculation rate 
                fps.exec ~>
                    #console.warn "re-calculating inner html"
                    set-container-height!
