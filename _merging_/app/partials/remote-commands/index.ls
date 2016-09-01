require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    SwitchActor,
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


RactivePartial!register ->
  cmd = SwitchActor 'gui-command'

  cmd.add-callback (msg) ->
    if msg.val
      console.log 'reloading due to remote command...'
      location.reload!
