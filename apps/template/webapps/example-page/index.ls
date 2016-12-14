ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('layout.html')
    data:
        name: "guest"
