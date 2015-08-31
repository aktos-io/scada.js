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
  }
}
  
module.exports = {
  envelp, get-msg-body, Actor, ProxyActor, RactivePartial
}