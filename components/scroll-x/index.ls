# creates a container that fits the parent width and scroll
require! 'aea': {sleep}

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
        outer = $ @find \.scroll-x-outer
        container = $ @find \.scroll-x-container
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
