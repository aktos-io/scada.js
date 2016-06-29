(function(){
  var ref$, split, take, join, listsToObj, Str, BarChart, myData, simulateData, ractive;
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, Str = ref$.Str;
  Ractive.DEBUG = /unminified/.test(function(){});
  BarChart = Ractive.extend({
    template: '#bar-chart',
    data: {
      getColor: function(order){
        var colors;
        colors = ['#d9534f', '#5bc0de', '#5cb85c', '#f0ad4e', '#337ab7'];
        return colors[order];
      },
      getShortName: function(name){
        return Str.take(6, name) + "...";
      }
    }
  });
  myData = [
    {
      name: "son kullanma tarihi geçmiş",
      amount: 15
    }, {
      name: "müşteri iade",
      amount: 80
    }, {
      name: "hatalı sipariş",
      amount: 23
    }
  ];
  simulateData = function(){
    var reasons, random, x;
    reasons = ["Son kullanma tarihi geçmiş", "Müşteri İade", "Hatalı Sipariş", "Hayat zor"];
    random = function(){
      return parseInt(Math.random() * 100);
    };
    return x = (function(){
      var i$, x$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = reasons).length; i$ < len$; ++i$) {
        x$ = ref$[i$];
        results$.push({
          name: x$,
          amount: random()
        });
      }
      return results$;
    }());
  };
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myData: myData,
      simulateData: simulateData
    },
    components: {
      "bar-chart": BarChart
    }
  });
}).call(this);
