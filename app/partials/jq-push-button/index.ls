require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
RactivePartial!register ->
  console.log "bootstrap-checkboxes are initialized..."
  $ '.jq-push-button .button-checkbox' .each ->
    console.log "checkbox is initialized...", $ this
    widget = $ this
    button = widget.find 'button'
    checkbox = widget.find 'input:checkbox'
    color = button.data \color
    settings =
      on: icon: 'fa fa-square'
      off: icon: 'fa fa-square-o'

    button.data \on-icon, settings.on.icon
    button.data \off-icon, settings.off.icon


    update-display = ->
      is-checked = checkbox.is \:checked

      button.data \state, if is-checked then \on else \off

      button.find \.state-icon
        .remove-class!
        .add-class 'state-icon ' + if is-checked then button.data \on-icon else button.data \off-icon

      if is-checked
        button
          .removeClass 'btn-default'
          .addClass('btn-' + color + ' active')
      else
        button
          .removeClass('btn-' + color + ' active')
          .addClass('btn-default')

    checkbox.on \change, ->
      console.log "checkbox change run"
      update-display!

    checkbox.on \update-display, -> update-display!

    init = ->
      update-display!
      if button.find('.state-icon').length == 0
          button.prepend('<i class="state-icon ' + settings[button.data('state')].icon + '"></i> ')

    init!


RactivePartial! .register-for-document-ready ->
  $ '.jq-push-button' .each ->
    #console.log "found push-button!"
    actor = IoActor $ this
    button = actor.node.find 'button'
    checkbox = actor.node.find 'input:checkbox'

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    icon-param = actor.get-ractive-var \icon
    if icon-param?
      [on-icon, off-icon] = icon-param.split ' '
      console.log "on off icons: ", on-icon, off-icon
      unless off-icon? then off-icon = on-icon
      button.data \on-icon, "fa fa-#{on-icon}"
      button.data \off-icon, "fa fa-#{off-icon}"
      checkbox.trigger \update-display

    turn = (state) ->
      checkbox.prop \checked, state
      checkbox.trigger \change

    # desktop support
    button.on 'mousedown' ->
      console.log "mousedown detected"
      turn on
      button.on 'mouseleave', ->
        turn off

    button.on 'mouseup' ->
      turn off
      button.off 'mouseleave'

    # touch support
    button.on 'touchstart' (e) ->
      turn on
      button.touchleave ->
        turn off
      e.stop-propagation!

    button.on 'touchend' (e) ->
      turn off

    i = 0
    checkbox.change ->
      state = checkbox.is \:checked
      console.log "jq-checkbox changed: #state", i
      i := i + 1
      actor.gui-event state

    actor.add-callback (msg) ->
      checkbox.prop 'checked', msg.val
      checkbox.trigger \update-display
