require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

require! {
  '../../modules/prelude': {
    flatten,
    initial,
    drop,
    join,
    concat,
    tail,
    head,
    map,
    zip,
    split,
    last,
  }
}

# Handle page navigation
# -----------------------
handle-navigation = (event) ->
  page = window.location.hash.replace /^#/, '' .split '/'
  console.log "hash changed: #{page}"

  change-page = (target-id) ->
    console.log "page is changed to #{target-id}"
    $ ':mobile-pagecontainer' .pagecontainer 'change', target-id, do
      transition: \none


  # try to scroll to anchor, immediately or after page change
  scroll-to-anchor = (anchor) ->
    # anchor may be
    #   * simple anchor in page
    #   * popup
    #   * subpage

    if anchor? and anchor isnt ''
      console.log "navigate to anchor: #{anchor}"
      anchor-str = '#' + anchor
      if ($ anchor-str .data \role) is \popup
        # this is a popup
        console.log "#{anchor-str} is a popup link!"
        target = anchor-str.replace /!$/, ''
        popup-options = {}

        if event?
          console.log "handle navigation got event: ", event
          popup-options <<< do
            x: event.client-x
            y: event.client-y

        $ target .popup \open, popup-options

        # remove popup link portion from url on close
        /*
        TODO: fix this function. this function makes the popup close on open
        $ target .on \popupafterclose, (event) ->
          console.log "the popup is closed! replacing #{anchor} with ''"
          window.location.hash = window.location.hash.replace anchor, ''
          $ target .off \popupafterclose
        */
        $ document .mouseup (e) ->
          container = $ target
          if not container.is e.target and container.has e.target .length is 0
            #container.hide!
            console.log "the popup is closed! replacing #{anchor} with ''"
            window.location.hash = window.location.hash.replace anchor, ''

      else if ($ anchor-str .data \role) is \page
        change-page anchor-str
      else
        try
          target = $('#' + anchor).offset!top
          target -= 5px  # give a default margin
          #$.mobile.silent-scroll target
          $ 'html, body' .animate {scroll-top: target}, 10
        catch
          # pass

  if page.length is 1
    # example: #abcd
    # this is a anchor, just navigate to it
    scroll-to-anchor page.0
  else
    #          #/aaaa             : aaaa is page
    #          #/aaaa/bbbb        : aaaa is page, bbbb is anchor


    main-section = if page.1? and page.1.length > 0 then
      page.1
    else
      'home-page'
    anchor = page.2

    change-page ('#' + main-section)

    # scroll immediately (in the same page)
    scroll-to-anchor anchor
    # .. and after page chaged
    $ document .on \pageshow, ->
      scroll-to-anchor anchor
      $ document .off \pageshow

RactivePartial! .register-for-document-ready ->
  handle-navigation!

RactivePartial! .register-for-post-ready ->
  $ window .on \hashchange, ->
    console.log "hash changed, handling navigation..."
    handle-navigation!

  # modify anchors to point their current pages
  $ \a .click (e) ->
    addr = $ this .attr \href
    if addr.match /^#.*/
      # this is an internal link
      console.log "link orig addr: #{addr}, length: #{addr.length}"
      addr = tail addr
      if addr.match /^[^\/]+/ or addr is ''
        # this link refers to an anchor (like #foo)
        e.prevent-default!
        curr-page = window.location.hash.replace /^#/, '' .split '/' .1
        if curr-page?
          console.log "click function is called! curr-page: #{curr-page}"
          new-hash = '#' + "/#{curr-page}/#{addr}"
          #window.location.hash = new-hash
          history.pushState({}, '', new-hash)

    handle-navigation e
