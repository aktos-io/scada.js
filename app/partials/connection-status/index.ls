require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register-for-document-ready ->
  $ '.connection-status' .each ->
    actor = IoActor $ this 