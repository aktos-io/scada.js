require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
    formatter,
  }
}

RactivePartial! .register ->
  $ \.seven-segment .each ->
    actor = IoActor $ this

    display = actor.node.find \.seven-segment__display

    format = (actor.get-ractive-var 'format') ? '###'

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

      
    widget-formatter = formatter format
    display-format = widget-formatter actor.get-ractive-var \val

    params =
      value: display-format.value
      color-off: "#120000"
      color-on: "red"
      digits: display-format.digits

    height = 50px
    width = height * 0.75 * params.digits
    actor.node.css \width, width
    actor.node.css \height, height
    #console.log "height: #height setting width: #width"

    type = actor.get-ractive-var 'type'

    if type is \multimeter
      params = $.extend params, do
        color-off: "#001200"
        color-on: "Lime"

    display.seven-seg params

    actor.add-callback (msg) ->
      #console.log "seven segment display got message: ", msg.val
      display.seven-seg value: (widget-formatter msg.val).value
