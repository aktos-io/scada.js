Ractive.components.icon = Ractive.extend do
    template: "<i class='icon {{class}}'></i> {{yield}}"

Ractive.components.icons = Ractive.extend do
    template: '<i class="icons {{class}}">{{yield}}</i>'
