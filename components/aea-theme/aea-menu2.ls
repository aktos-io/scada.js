require! 'aea': {sleep}

Ractive.components["aea-menu2"] = Ractive.extend do
    template: require('aea-menu2.pug')
    isolated: yes
    data: ->
        debug: no
        is-menu-open: no
        is-menu-automatically-opened: no
        submenu-state: {}

    onrender: ->
        __ = @
        main-sidebar = $ @find \.main-sidebar
        main-sidebar-button = $ @find \.main-sidebar-button

        if $ window .width! >= 1200
            __.set \isMenuOpen, yes

        @observe \debug, (_new) ->
            if _new
                main-sidebar.addClass \debug
            else
                main-sidebar.removeClass \debug


        @observe \isMenuOpen, ->
            if __.get \isMenuOpen
                # open the menu
                main-sidebar .removeClass \collapsed
            else
                # close the menu
                main-sidebar .addClass \collapsed
                $ \.sub-menu-open .removeClass \sub-menu-open
                $ \.glyphicon-chevron-up .removeClass \glyphicon-chevron-up .addClass \glyphicon-chevron-down
            # We just assume these menu is opened and the *user* is involved
            # BUT automatic operations update `isMenuAutomaticallyOpened`
            # afterwards
            __.set \isMenuAutomaticallyOpened, no

        main-sidebar-button .click !->
            __.toggle \isMenuOpen

        $ '.sidebar-menu li>a' .click !->
            if __.get \isMenuAutomaticallyOpened or $ window .width! < 1200
                __.set \isMenuOpen, no

        @on do
            toggleSubmenu: (index) ->
                unless __.get \isMenuOpen
                    __.set \isMenuOpen, yes
                    __.set \isMenuAutomaticallyOpened, yes

                submenuState = @get \submenuState
                submenuState[index] = not submenuState[index]
                @set \submenuState, submenuState

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
