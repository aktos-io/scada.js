require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ \.spinbox .each !-> 
    actor = IoActor $ this
        
    actor.add-callback (msg) ->
      actor.set-ractive-var \val, msg.val
      #console.log "this is original spinbox: ", actor.actor-id
          
    input = actor.node.find \.spinbox__data-input
    input.on \change, ->
      actor.gui-event input.val!
      
/*Debugger Widget Example
RactivePartial! .register ->
  $ \.spinbox .each !-> 
  
    actor = IoActor $ this 

    actor.add-callback (msg) ->
      console.log 'Spinbox debugger plugin:  ', msg.val, actor.actor-id
*/