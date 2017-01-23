
component-name = "aea-theme"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-theme')

# component-name = "aea-menu"
# Ractive.components[component-name] = Ractive.extend do
#     template: RACTIVE_PREPARSE('index.pug', '#aea-menu')
#     isolated: yes
#     data: ->
#         expand: yes
#         show-submenu: no

component-name = "aea-menu2"
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

        if $ window .width! > 1200
            __.set \isMenuOpen, yes
            main-sidebar .removeClass \collapsed

        main-sidebar-button .click !->
            if __.get \isMenuOpen
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

        do function hashchange
            hash = window.location.hash
            hash = '/' unless hash

            is-match-found = no

            for x in __.get \menu
                if x.url is \# or (not x.url and not x.sub-menu)
                    continue

                if x.url is hash
                    is-match-found = yes

                    $ \.sidebar-menu .find \.active .removeClass \active
                    $ \.sidebar-menu .find 'a[href="' + hash + '"]' .addClass \active

                    break

                if x.sub-menu
                    for y in x.sub-menu
                        if y.url is \# or (not y.url and not y.sub-menu)
                            continue

                        if y.url is hash
                            is-match-found = yes

                            $ \.sidebar-menu .find \.active .removeClass \active
                            $ \.sidebar-menu .find 'a[href="' + hash + '"]' .addClass \active .parent! .parent! .siblings \.anchor .addClass \active

                            break

                if is-match-found
                    break

        $ window .on \hashchange, -> hashchange!

component-name = "aea-content"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug', '#aea-content')
