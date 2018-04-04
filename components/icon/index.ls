Ractive.components.icon = Ractive.extend do
    template: '<i class="icon {{class}}" on-click="click"></i> {{yield}}'

Ractive.components.icons = Ractive.extend do
    template: '<i class="icons {{class}}" on-click="click">{{yield}}</i>'
