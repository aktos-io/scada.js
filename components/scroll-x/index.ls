# creates a container that fits the parent width and scroll
require! 'aea': {sleep}

Ractive.components['scroll-x'] = Ractive.extend do
    template: '''
        <div class="scroll-x-container">
            {{yield}}
        </div>
    '''
    isolated: no
    onrender: ->
        container = $ @find \.scroll-x-container

        do set-parent-width = ->
            container .css \width, \1px  # This is important in order to calculate parent width
            container.css \width, container.parent!.width!

        $ window .resize -> set-parent-width!
