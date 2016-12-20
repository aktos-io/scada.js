require('components');

var ractive = new Ractive({
  el: '#main-output',
  template: RACTIVE_PREPARSE('content.html'),
  data: {
    name: "guest"
  }
});
