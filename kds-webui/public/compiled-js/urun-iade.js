(function(){
  var ref$, split, take, join, listsToObj, sum, StackedBarChart, convertReasonToSbc, getReturnReasons, returnReasons, ractive;
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  Ractive.DEBUG = /unminified/.test(function(){});
  StackedBarChart = Ractive.extend({
    template: '#stackedchart',
    data: {
      getColor: function(order){
        var colors;
        colors = ['#d9534f', '#5bc0de', '#5cb85c', '#f0ad4e', '#337ab7'];
        console.log("color: ", colors[order]);
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
        console.log("data-list: ", dataList);
        r = [];
        for (i$ = 0, len$ = dataList.length; i$ < len$; ++i$) {
          i = dataList[i$];
          console.log("i : ", i);
          dataPoint = {
            name: i.name,
            amount: i.amount
          };
          dataPoint.startX = sum((fn$()));
          dataPoint.centerX = dataPoint.startX + dataPoint.amount / 2;
          console.log("sum: ", dataPoint.startX);
          r = r.concat([dataPoint]);
          console.log("r: ", r);
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
  convertReasonToSbc = function(x){
    var r, res$, i$, x$, len$;
    res$ = [];
    for (i$ = 0, len$ = x.length; i$ < len$; ++i$) {
      x$ = x[i$];
      res$.push({
        name: x$.reason,
        amount: x$.amount
      });
    }
    r = res$;
    console.log("...: ", r);
    return r;
  };
  getReturnReasons = function(){
    var names, reasons, random, i$, x$, len$, results$ = [];
    names = ["Haydari", "Rus salata", "Mercimek", "İçli Köfte", "Sarma", "Dolma", "Patlıcan Ezme", "Biber Dolma", "Patates Közleme", "Balık Buğulama", "Ayva Güllacı", "Mahmut Beğendi"];
    reasons = ['SKT', 'AAA', 'BBB', 'CCC'];
    random = function(){
      return parseInt(Math.random() * 100);
    };
    for (i$ = 0, len$ = names.length; i$ < len$; ++i$) {
      x$ = names[i$];
      results$.push({
        name: x$,
        returnReasons: (fn$())
      });
    }
    return results$;
    function fn$(){
      var i$, x$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = reasons).length; i$ < len$; ++i$) {
        x$ = ref$[i$];
        results$.push({
          reason: x$,
          amount: random()
        });
      }
      return results$;
    }
  };
  returnReasons = [
    {
      name: 'Haydari',
      returnReasons: [
        {
          reason: "son kullanma tarihi geçmiş",
          amount: 15
        }, {
          reason: "müşteri iade",
          amount: 80
        }, {
          reason: "hatalı sipariş",
          amount: 23
        }
      ]
    }, {
      name: "Rus Salatası",
      returnReasons: [
        {
          reason: "son kullanma tarihi geçmiş",
          amount: 11
        }, {
          reason: "müşteri iade",
          amount: 35
        }, {
          reason: "hatalı sipariş",
          amount: 49
        }
      ]
    }
  ];
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      returnReasons: getReturnReasons(),
      convertReasonToSbc: convertReasonToSbc
    },
    components: {
      'stacked-bar-chart': StackedBarChart
    }
  });
}).call(this);
