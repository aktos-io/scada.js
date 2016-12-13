ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('layout.pug')
    data:
        name: "guest"
