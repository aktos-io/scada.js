(function(){
  var ref$, split, take, join, listsToObj, sum, StackedBarChart, myData, simulateData, ractive;
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  Ractive.DEBUG = /unminified/.test(function(){});
  StackedBarChart = Ractive.extend({
    template: '#stacked-bar-chart',
    data: {
      getColor: function(order){
        var colors;
        colors = ['#d9534f', '#5bc0de', '#5cb85c', '#f0ad4e', '#337ab7'];
        return colors[order];
      },
      getGraphData: function(dataList){
        /* this function returns list of data points
            in order to draw a stacked progress bar.
        
            input data format:
        
                input-data =
                    * name: "My data 1"
                      amount: amount1
                    * name: "My data 2"
                      amount: amount2
        
            data format is as follows:
        
                points =
                    * name: "My data 1"
                      amount: amount1
                      start-x: 0
                      center-x: start-x + amount1 / 2
                    * name: "My data 2"
                      amount: amount2
                      start-x: 0 + amount1
                      center-x: start-x + amount2 / 2
                    * name: "My data 3"
                      amount: amount3
                      start-x: 0 + amount1 + amount2
                      center-x: start-x + amount3 / 2
                    ...
        */
        var r, i$, len$, i, dataPoint;
        r = [];
        for (i$ = 0, len$ = dataList.length; i$ < len$; ++i$) {
          i = dataList[i$];
          dataPoint = {
            name: i.name,
            amount: i.amount
          };
          dataPoint.startX = sum((fn$()));
          dataPoint.centerX = dataPoint.startX + dataPoint.amount / 2;
          r = r.concat([dataPoint]);
        }
        return r;
        function fn$(){
          var i$, x$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = r).length; i$ < len$; ++i$) {
            x$ = ref$[i$];
            results$.push(x$.amount);
          }
          return results$;
        }
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
      simulateData: simulateData,
      myData: myData
    },
    components: {
      'stacked-bar-chart': StackedBarChart
    }
  });
}).call(this);
