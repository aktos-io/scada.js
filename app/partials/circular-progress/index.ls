require! {
  '../../modules/aktos-dcs': {
    RactivePartial,
    
  }
}


RactivePartial! .register ->
  console.log "Circular-Progress"
  
  $ \.circle1 .circle-progress do       
    value: 0.35
    size: 80
    animation: false
    fill: do
      gradient: ['#ff1e41', '#ff5f43']
  
  $ \.circle2 .circle-progress do
    value: 0.6
  .on 'circle-animation-progress', (event, progress) ->
    $ this .find \strong .html parse-int(100 * progress) + '<i>%</i>'
  
  
  $ \.circle3 .circle-progress do
    value: 0.75
    fill: do
      gradient: [['#0681c4', 0.5], ['#4ac5f8', 0.5]]
      gradientAngle: Math.PI / 4
  .on 'circle-animation-progress', (event, progress, step-value) ->
    $ this .find \strong .text String(step-value.toFixed(2)).substr 1  
  
