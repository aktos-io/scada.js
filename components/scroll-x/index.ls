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
        outer.css \height, container.height!
