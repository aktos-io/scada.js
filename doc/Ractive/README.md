# Conditional Event Declaration

```pug
input(value="{{hello}}")
ack-button("{{#if hello}}on-click='@.global.alert()'{{/if}}") helloooo
```

# Propagating `context.hasListener()` behaviour

```pug
mycomp(
    "{{#if @this.getContext().hasListener('hello')}}on-hello='hello'{{/if}}"
    )
```
[Playground](https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SAbAhgFwKYGcUgL4BoQN4AlJAYxQEsA3NAOjIHsBbAB0YDs0OUM7mAnkzYACALwjSFGvTQAPdBwAmACmAAdDupTo2ydJBEADTdu0AeAEYBXHZxGcAtGQSUyAazHrwaBAkbeAHymKGYowMAClL5KODgiIWERAMSUAGYiGCxoAAowjKxxiaElKkpo6BRoSiJIIq5Y3GgwAJTF2hG+GGhFWiVhKhyMKCLlleg1dQ2KzW19ScAA9Om9YeaLNnYcwX1GeCGclByUKIZp1hzSnCoUci0a81QZNyhydGBIGAAylI1cMCoAORgXz+QF4EQoGDWNAte7tHRgX50booIFZZi5fKscGQ6GwgDcxRwIXwISUqCQZwuVw4KnhjxgFWsMA4IgeYW0GKxBTOSAQ3WJpM0ODmmikVFoDBY7C4PD4ggw1lYzWErHEknIktkCm4qg5OjQelQaEMJke5iUNEyKAECDQXhAlkYMHKMEMACZWHJRp8QTVLMgPASRMwkDAAOZHQwARiNIdYSCUVo4EdjAAZvSGrRhWMgBIYjq4uI5A4wPEEEeZBGr2cBUhkAAIoJF8CMVADCnHQCnp70+Pz+zSBIL8jEBLTiTlH-kdM4CIAiyzScUCESiMTi6xrMp2a0WVuoe5Q5tFpg4XAA7prpLQ1CFfIZAc6lAJwSFdHmTWbitWhDKHA4Rx50dFtmjQIIAAlPhEed6l+GYYG3f82GPCwd1EQJoIwEQADkAHlYNBRh4KHJDFgw1g0JQP8lRVGBa2nYjQJBJkoJguDpiacjFWVVVd1-Xj6LVLCYIIoix1IxDkLo-jUJCPYEj6ThDANbQwKZalLioa5bgZTkUH5Zo0WBNA3zFEoST6KzRVwIA)
