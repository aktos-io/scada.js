require('components');

var ractive = new Ractive({
  el: '#main-output',
  template: RACTIVE_PREPARSE('app.html'),
  data: {
    name: "guest"
  }
});
