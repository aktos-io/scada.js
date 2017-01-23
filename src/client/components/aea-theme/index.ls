
component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

component-name = "aea-menu"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-menu')
    isolated: yes
    data: ->
        expand: yes
        is-menu-open: no
    onrender: ->
        __ = @
        main-sidebar = $ @find \.main-sidebar
        main-sidebar-button = $ @find \.main-sidebar-button

        if $ window .width! < 1200
            __.set \isMenuOpen no
            main-sidebar .addClass \collapsed

        main-sidebar-button .click !->
            if !__.get \isMenuOpen
                # close the menu

                main-sidebar .addClass \collapsed
                $ \.sub-menu-open .removeClass \sub-menu-open
                $ \.glyphicon-chevron-up .removeClass \glyphicon-chevron-up .addClass \glyphicon-chevron-down
            else
                # open the menu

                main-sidebar .removeClass \collapsed

            __.set \isMenuOpen, !__.get \isMenuOpen
        $ \.anchor .click !->
            $ this .next \.sub-menu .toggleClass \sub-menu-open
            $ this .children \.menu-item-dropdown .toggleClass \glyphicon-chevron-down .toggleClass \glyphicon-chevron-up

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')
