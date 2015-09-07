require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    IoActor,
  }
}
  
RactivePartial! .register ->
  $ \.gauge .each ->
    
    elem = $ this
    actor = IoActor elem
    
    element-id = actor.actor-id
    console.log "göstergeler test" + element-id
    actor.set-ractive-var 'actor_id', element-id
    
    type = actor.get-ractive-var \type
    
    params = 
      width: 300
      height: 300
      renderTo: element-id
      glow: true
      highlights: do
        [
          from: 40
          to: 60
          color: \PaleGreen
          do
            from: 60
            to: 80
            color: \Khaki
          do
            from: 80
            to: 100
            color: \LightSalmon
        ]
      animation: do
        delay: 10
        duration: 300
        fn: \bounce
      colors: do
        title: \green
    
    if type is \upload
      params.units = \Mbps
      params.title = \Upload
      params.strokeTicks = false
    else if type is \download
      params.width = 200
      params.height = 200
      params.highlights = false
      params.units = \Mbps
      params.title = \Download
    else if type is \ping
      params.width = 300
      params.height = 300
      params.glow = false
      params.units = \ms
      params.title = \Ping
      params.max-value = 1000
      params.major-ticks = ['0','100','200','300','400','500','600','700','800','900','1000']
      params.highlights = false
      params.value-format = { int : 4, dec : 1 }
      params.colors.needle = { start : 'lightgreen', end : 'navy' }
      params.colors.plate = \lightyellow
      params.colors.title = \green
      params.colors.units = \lightgreen
      params.colors.major-ticks = \darkgreen
      params.colors.minor-ticks = \lightgreen
      params.colors.numbers = \darkgreen
      params.animation.delay = 25
      params.animation.duration = 500
      params.animation.fn = \elastic
    else if type is \speed
      params.units = \Kmh
      params.min-value = 0
      params.max-value = 220
      params.major-ticks = ['0','20','40','60','80','100','120','140','160','180','200','220']
      params.minor-ticks = 2
      params.highlights = [
        { from : 0,   to : 50, color : 'rgba(0,   255, 0, .15)' },
        { from : 50, to : 100, color : 'rgba(255, 255, 0, .15)' },
        { from : 100, to : 150, color : 'rgba(255, 30,  0, .25)' },
        { from : 150, to : 200, color : 'rgba(255, 0,  225, .25)' },
        { from : 200, to : 220, color : 'rgba(0, 0,  255, .25)' }]
      params.colors.needle = { start : 'rgba(240, 128, 128, 1)', end : 'rgba(255, 160, 122, .9)' }
      params.colors.plate = \#222
      params.colors.title = \#fff
      params.colors.units = \#ccc
      params.colors.numbers = \#eee
      params.colors.major-ticks = \#f5f5f5
      params.colors.minor-ticks = \#ddd
      

      

    
    gauge = new Gauge params
    
    gauge.draw!
    
    actor.add-callback (msg) ->
      gauge.set-value msg.val