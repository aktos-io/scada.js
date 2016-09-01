require! {
  './aktos-dcs': {
    envelp,
    get-msg-body,
    Actor,
    ProxyActor,
  }
}

require! {
  './widgets': {
    RactivePartial,
    get-ractive-var,
    set-ractive-var,
    RactiveApp,
  }
}

require! {
  './aktos-dcs-lib': {
    SwitchActor,
    WidgetActor,
    IoActor,
    AuthActor,
  }
}

require! {
  './formatter': {
    formatter, act-get-range, act-get-fmt
  }
}



module.exports = {
  envelp, get-msg-body, Actor, ProxyActor,
  RactivePartial, get-ractive-var, set-ractive-var, RactiveApp,
  SwitchActor, WidgetActor, IoActor, AuthActor,
  formatter, act-get-range, act-get-fmt, 
}
