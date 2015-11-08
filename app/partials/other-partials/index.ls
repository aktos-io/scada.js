require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
  }
}

RactivePartial!register-for-document-ready ->
  console.log "navbar ls is running..."
  $ ".navbar a" .each ->
    console.log "menu anchor is being modified...."
    $ this .data \custom-click, true
    $ this .click (event) ->
      $ ".navbar-collapse" .collapse 'hide'
      console.log "navbar collapsed..."
