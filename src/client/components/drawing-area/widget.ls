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
