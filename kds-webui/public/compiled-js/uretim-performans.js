(function(){
  var ref$, split, take, join, listsToObj, Str, BarChart, getReturnProduction, myData, ractive;
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
  getReturnProduction = function(productName){
    var x;
    return x = (function(){
      var i$, x$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = myData).length; i$ < len$; ++i$) {
        x$ = ref$[i$];
        if (x$.name === productName) {
          results$.push(x$.production);
        }
      }
      return results$;
    }())[0];
  };
  myData = [
    {
      name: 'Haydari',
      production: [
        {
          date: "12.02.2005",
          planned: 24,
          produced: 12
        }, {
          date: "12.12.2012",
          planned: 55,
          produced: 33
        }, {
          date: "12.12.2016",
          planned: 123,
          produced: 97
        }
      ]
    }, {
      name: 'Rus',
      production: [
        {
          date: "10.02.2005",
          planned: 24,
          produced: 12
        }, {
          date: "10.12.2012",
          planned: 49,
          produced: 45
        }, {
          date: "10.12.2016",
          planned: 96,
          produced: 87
        }
      ]
    }, {
      name: 'Ezme',
      production: [
        {
          date: "01.01.2012",
          planned: 9,
          produced: 9
        }, {
          date: "02.03.2013",
          planned: 22,
          produced: 19
        }, {
          date: "23.11.2016",
          planned: 23,
          produced: 46
        }
      ]
    }
  ];
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myData: myData,
      getReturnProduction: getReturnProduction
    },
    components: {
      "bar-chart": BarChart
    }
  });
}).call(this);
