# User management

### `Ractive.isAble()`

Available in: template, code. Implemented in `components/aktos-dcs`.

Description: Checks if current user has `that` permission. Permissions are the strings listed in `permissions` field in the user definition.


 `permission`: Topic type.

On GUI side:

    {{#if isAble('some.permission')}}
        has this permission
    {{else}}
        don't have this permission
    {{/if}}


    or

    {{#if isUnable('somePermission')}}
        client doesn't have this permission
    {{/if}}


On Javascript side, in Ractive context:

    if @get 'somePermission' then /* user has this permission */