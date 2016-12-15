ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('content.html')
    data:
        name: "guest"
