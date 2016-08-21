require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    RactiveApp,
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
    reverse,
  }
}

change-page = (target-id) ->
  # target-id: the target div id (without the hash)
  # example:
  #
  #     change-page 'my-page'
  #     # => this will change page to "<div id='my-page' data-role='page'>...</div>"
  #
  target = $ ('#' + target-id)
  default-page = 'home-page'

  if (target?.data \role) is \page
    $ "*[data-role='page'] " .css \display, \none
    $ '#loading' .css \display, \none
    target.css \display, \block
    RactiveApp!get!set \page.active_page, target-id
    console.log "active page is: ", RactiveApp!get!get \page.active_page
  else
    console.log "target (#{target-id}) is not a page, redirecting to default!"
    change-page default-page


scroll-to-anchor = (anchor) ->
  # anchor may be
  #   * simple anchor in page
  if anchor? and anchor isnt ''
    console.log "navigate to anchor: #{anchor}"
    anchor-str = '#' + anchor

    try
      target = $('#' + anchor).offset!top
      target -= 5px  # give a default margin
      #$.mobile.silent-scroll target
      $ 'html, body' .animate {scroll-top: target}, 10
    catch
      # pass

# Handle page navigation
# -----------------------
handle-navigation = (event) ->
  addr = window.location.hash
  console.log "original window.hash is: ", addr
  if addr in ['', '#/']
    console.log "redirecting to default page"
    change-page!
  else
    section = addr.replace /^#/, '' .split '/'
    console.log "hash changed: #{section}"

    closest-page = [.. for reverse section when ($ ('#' + ..) .data \role) is \page].0
    console.log "closest page is: #{closest-page}"

    change-page closest-page
    last-anchor = [.. for reverse section when ($ ('#' + ..) .data \role) isnt \page].0

    if last-anchor?
      console.log "scrolling to anchor: #{last-anchor}"
      s = ->
        scroll-to-anchor last-anchor
      set-timeout s, 10


RactivePartial!register ->
  console.log "all divs are hidden"
  $ "*[data-role='page'] " .css \display, \none

RactivePartial! .register-for-post-ready ->
  $ window .on \hashchange, ->
    console.log "hash changed to #{window.location.hash}, handling navigation..."
    handle-navigation!

  # modify anchors to point their current pages
  $ \a .each ->
    addr = $ this .attr \href
    custom-click = ($ this .data \custom-click) ? false

    /*
    if custom-click
      console.log "this ancor will not be modified: "
    else
      console.log "this is not a custom click function"
    */

    if addr? and not custom-click
      anchor-page = $ this .closest "[data-role='page']" .attr \id
      #console.log "anchor address is #{addr} and is under", anchor-page
      if addr.match /^#[a-zA-Z0-9_]+/ or addr is '#'
        # this is in-page link (eg. <a href="#abc/def"></a>)
        new-hash = ('#/' + anchor-page + '/' + tail addr)
        $ this .attr \href, new-hash
      $ this .click ->
        history.pushState({}, '', new-hash)
        handle-navigation!

RactivePartial! .register-for-post-ready ->
  # run on page load
  console.log "internal redirect on first load..."
  handle-navigation!
