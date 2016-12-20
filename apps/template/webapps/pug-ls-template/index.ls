require! components

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('content.pug')
    data:
        name: "guest"
