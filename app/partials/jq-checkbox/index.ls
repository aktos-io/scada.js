require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}

RactivePartial!register ->
  console.log "bootstrap-checkboxes are initialized..."
  $ '.jq-checkbox .button-checkbox' .each ->
    console.log "checkbox is initialized...", $ this
    widget = $ this
    button = widget.find 'button'
    checkbox = widget.find 'input:checkbox'
    color = button.data \color
    settings =
      on: icon: 'fa fa-check-square'
      off: icon: 'fa fa-square-o'

    update-display = ->
      is-checked = checkbox.is \:checked

      button.data \state, if is-checked then \on else \off

      button.find \.state-icon
        .remove-class!
        .add-class 'state-icon ' + settings[button.data('state')].icon

      if is-checked
        button
          .removeClass 'btn-default'
          .addClass('btn-' + color + ' active')
      else
        button
          .removeClass('btn-' + color + ' active')
          .addClass('btn-default')

    button.on \click, ->
      state = checkbox.is \:checked
      checkbox.prop \checked, not state
      checkbox.trigger \change
      update-display!

    checkbox.on \change, ->
      console.log "checkbox change run"
      update-display!

    checkbox.on \update-display, -> update-display!

    init = ->
      update-display!
      if button.find('.state-icon').length == 0
          button.prepend('<i class="state-icon ' + settings[button.data('state')].icon + '"></i> ')

    init!


RactivePartial! .register ->
  $ '.jq-checkbox' .each !->
    actor = IoActor $ this

    if (actor.get-ractive-var \wid)?
      actor.node.add-class \draggable

    input = actor.node.find \input

    i = 0
    input.change ->
      state = input.is \:checked
      console.log "jq-checkbox changed: #state", i
      i := i + 1
      actor.gui-event state

    actor.add-callback (msg) ->
      input.prop 'checked', msg.val
      input.trigger \update-display
