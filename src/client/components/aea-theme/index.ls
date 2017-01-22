
component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-menu')
    isolated: yes
    data: ->
        expand: yes
        show-submenu: no
    onrender: ->
        __ = @
        main-sidebar = $ @find \.main-sidebar
        main-sidebar-button = $ @find \.main-sidebar-button

        main-sidebar-button .click !->
            if !__.get \showSubmenu
                # close the menu

                main-sidebar .addClass \collapsed
                $ \.sub-menu-open .removeClass \sub-menu-open
                $ \.glyphicon-chevron-up .removeClass \glyphicon-chevron-up .addClass \glyphicon-chevron-down
            else
                # open the menu

                main-sidebar .removeClass \collapsed

            __.set \showSubmenu, !__.get \showSubmenu
        $ \.menu-item-dropdown .click !->
            $ this .parent! .next \.sub-menu .toggleClass \sub-menu-open
            $ this .toggleClass \glyphicon-chevron-down .toggleClass \glyphicon-chevron-up

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')
