component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade', '#aea-theme')

component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade', '#aea-menu')
    isolated: yes
    onrender: ->
        __ = @
        user = __.get \user

    data: ->
        __ = @
        is-role-match: (groups, roles) ->
            for group in groups
                for role in roles when role is group
                    return true
            return false
        user: null
        expand: yes

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade', '#aea-content')
