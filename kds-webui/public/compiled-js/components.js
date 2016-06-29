(function(){
  var ref$, split, take, join, listsToObj, Str, BarChart, myData, simulateData, ractive, sum, sleep, db, satisListesi, generateEntryId, getEntryId, getMaterials, opts, maximumBy, last, sortBy, LineChart, sort, PieChart, StackedBarChart, InteractiveTable, dataFromWebservice, decorateTableData, x, getReturnProduction, convertReasonToSbc, getReturnReasons, returnReasons;
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
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  sleep = function(ms, f){
    return setTimeout(f, ms);
  };
  db = null;
  satisListesi = null;
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myTableData: null,
      materials: []
    }
  });
  ractive.on({
    updateTable: function(){
      console.log("updating satis listesi!", satisListesi);
      db.put(satisListesi, function(err, res){
        return console.log("satıs listesi (put): ", err, res);
      });
      return sleep(1000, function(){
        return console.log("satis-listesi: :: ", satisListesi);
      });
    }
  });
  db = new PouchDB('mydb');
  db.sync(remote, {
    live: true
  });
  generateEntryId = function(userId){
    var timestamp;
    timestamp = new Date().getTime().toString(16);
    return userId + "-" + timestamp;
  };
  getEntryId = generateEntryId(5);
  getMaterials = function(){
    return db.query('primitives/raw-material-list', function(err, res){
      var materialDocument;
      console.log("this document contains raw material list: ", res);
      materialDocument = res.rows[0].id;
      return db.get(materialDocument, function(err, res){
        var materials, res$, i$, x$, ref$, len$;
        res$ = [];
        for (i$ = 0, len$ = (ref$ = res.contents).length; i$ < len$; ++i$) {
          x$ = ref$[i$];
          res$.push(x$.name);
        }
        materials = res$;
        console.log("these are materials: ", materials);
        return ractive.set('materials', materials);
      });
    });
  };
  opts = {
    since: 'now',
    live: true
  };
  db.changes(opts).on('change', function(){
    var x, res$, i$, to$;
    res$ = [];
    for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    x = res$;
    console.log("change detected!", x);
    return getMaterials();
  });
  db.info(function(){
    var x, res$, i$, to$;
    res$ = [];
    for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    x = res$;
    return console.log("info ::: ", x);
  });
  db.query('getTitles/new-view', function(err, res){
    console.log("getting titles: ", res);
    return db.allDocs({
      include_docs: true,
      keys: (function(){
        var i$, x$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = res.rows).length; i$ < len$; ++i$) {
          x$ = ref$[i$];
          results$.push(x$.key);
        }
        return results$;
      }())
    }, function(err, res){
      return console.log("documents related with titles: ", err, res);
    });
  });
  db.get("satış listesi", function(err, res){
    satisListesi = res;
    console.log("satış listesi: ", satisListesi);
    return ractive.set("myTableData", satisListesi.entries);
  });
  ref$ = require('prelude-ls'), maximumBy = ref$.maximumBy, last = ref$.last, sortBy = ref$.sortBy, split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  Ractive.DEBUG = /unminified/.test(function(){});
  LineChart = Ractive.extend({
    template: '#line-chart',
    init: function(){
      var points, scaledPoints, xLabels, res$, i$, to$, ridx$, height, yLabels;
      points = this.get("points");
      this.set("scaledPoints", this.scaledPoints);
      scaledPoints = this.scaledPoints();
      res$ = [];
      for (i$ = 0, to$ = last(scaledPoints).x; i$ <= to$; i$ += 10) {
        ridx$ = i$;
        res$.push(ridx$);
      }
      xLabels = res$;
      console.log("x-labels: ", xLabels);
      this.set("xLabels", xLabels);
      height = this.get('height');
      res$ = [];
      for (i$ = 0; i$ <= height; i$ += 50) {
        ridx$ = i$;
        res$.push(ridx$);
      }
      yLabels = res$;
      console.log("y-labels: ", yLabels);
      return this.set("yLabels", yLabels);
    },
    scaledPoints: function(){
      var points, sortedX, maxX, maxY, width, height, scaleFactorX, scaleFactorY, a, res$, i$, x$, len$, this$ = this;
      points = this.get("points");
      sortedX = sortBy(function(it){
        return it.x;
      }, points);
      maxX = last(sortedX).x;
      maxY = maximumBy(function(it){
        return it.y;
      }, points);
      width = this.get('width');
      height = this.get('height');
      scaleFactorX = width / maxX;
      scaleFactorY = height / maxY.y;
      res$ = [];
      for (i$ = 0, len$ = points.length; i$ < len$; ++i$) {
        x$ = points[i$];
        res$.push({
          x: x$.x * scaleFactorX,
          y: height - x$.y * scaleFactorY
        });
      }
      a = res$;
      return a;
    },
    data: {
      yLabels: null,
      xLabels: null,
      scaledPoints: null,
      convertToSvgPoints: function(points){
        /* --------------------------------------
        converts points for the following format:
        
            @points =
                * x: 1
                  y: 5
                * x: 15
                  y: 16
        
        to:
        
            "1 5,15 16"
        ---------------------------------------- */
        var scaledPoints, x;
        scaledPoints = this.scaledPoints();
        x = join(' ', (function(){
          var i$, x$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = points).length; i$ < len$; ++i$) {
            x$ = ref$[i$];
            results$.push(x$.x + ", " + x$.y);
          }
          return results$;
        }()));
        console.log(x);
        return x;
      }
    }
  });
  myData = [
    {
      x: 1,
      y: 1.5
    }, {
      x: 3,
      y: 4.5
    }, {
      x: 4,
      y: 5.5
    }, {
      x: 5,
      y: 3
    }, {
      x: 8.5,
      y: 10
    }, {
      x: 10,
      y: 0.8
    }
  ];
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myData: myData
    },
    components: {
      "line-chart": LineChart
    }
  });
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum, sort = ref$.sort;
  sleep = function(ms, f){
    return setInterval(f, ms);
  };
  Ractive.DEBUG = /unminified/.test(function(){});
  PieChart = Ractive.extend({
    template: '#pie-chart',
    oninit: function(){
      var colList, self;
      colList = split(',')(
      this.get('names'));
      this.set('columnList', colList);
      self = this;
      return sleep(this.get('delay'), function(){
        return self.animate('c', Math.PI * 2, {
          duration: 800,
          easing: 'easeOut'
        });
      });
    },
    init: function(options){
      return this.animate('c', Math.PI * 2);
    },
    data: {
      selected: null,
      names: null,
      columnList: null,
      c: 0,
      colors: ['red', 'green', 'blue', 'yellow'],
      getSegments: function(data){
        var total, start, segments;
        total = sum(data);
        data = sort(data);
        start = 0;
        segments = data.map(function(x){
          var size, end, segment;
          size = x / total;
          end = start + size;
          segment = {
            value: x,
            start: start,
            end: end
          };
          start = end;
          return segment;
        });
        console.log("segments: ", segments);
        return segments;
      },
      getSegmentPoints: function(segment, innerRadius, outerRadius){
        var points, start, end, getPoint, i$, angle;
        points = [];
        start = segment.start * this.get('c');
        end = segment.end * this.get('c');
        getPoint = function(angle, radius){
          return (radius * Math.sin(angle)).toFixed(2) + ',' + (radius * -Math.cos(angle)).toFixed(2);
        };
        for (i$ = start; i$ <= end; i$ += 0.05) {
          angle = i$;
          points[points.length] = getPoint(angle, outerRadius);
        }
        points[points.length] = getPoint(end, outerRadius);
        for (i$ = end; i$ >= start; i$ -= 0.05) {
          angle = i$;
          points[points.length] = getPoint(angle, innerRadius);
        }
        points[points.length] = getPoint(start, innerRadius);
        return points.join(' ');
      }
    }
  });
  simulateData = function(){
    var reasons, random, x, res$, i$, x$, len$;
    reasons = ["Son kullanma tarihi geçmiş", "Müşteri İade", "Hatalı Sipariş", "Hayat zor"];
    random = function(){
      return parseInt(Math.random() * 100);
    };
    res$ = [];
    for (i$ = 0, len$ = reasons.length; i$ < len$; ++i$) {
      x$ = reasons[i$];
      res$.push({
        name: x$,
        amount: random()
      });
    }
    x = res$;
    return x = (function(){
      var i$, x$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = reasons).length; i$ < len$; ++i$) {
        x$ = ref$[i$];
        results$.push(random());
      }
      return results$;
    }());
  };
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myData: [3, 5, 7, 99],
      simulateData: simulateData
    },
    components: {
      piechart: PieChart
    }
  });
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
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  Ractive.DEBUG = /unminified/.test(function(){});
  sleep = function(ms, f){
    return setTimeout(f, ms);
  };
  InteractiveTable = Ractive.extend({
    oninit: function(){
      var colList, self;
      colList = split(',')(
      this.get('cols'));
      this.set('columnList', colList);
      self = this;
      console.log("table content", this.get('content'));
      return this.on({
        activated: function(){
          var args, res$, i$, to$, index, currIndex;
          res$ = [];
          for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
            res$.push(arguments[i$]);
          }
          args = res$;
          index = parseInt(
          split('.')(
          args[0].keypath)[1]);
          console.log("activated!!!", args, index);
          currIndex = this.get('clickedIndex');
          if (index === currIndex) {
            console.log("Give tooltip!");
            this.fire('showModal');
          }
          return this.set('clickedIndex', index);
        },
        closeModal: function(){
          var self;
          self = this;
          $("#" + this.get('id') + "-modal").modal('hide');
          return sleep(300, function(){
            return self.fire('giveTooltip');
          });
        },
        giveTooltip: function(){
          var self, i;
          self = this;
          i = 0;
          return function lo(op){
            return sleep(150, function(){
              self.set('editTooltip', true);
              return sleep(150, function(){
                self.set('editTooltip', false);
                if (++i === 2) {
                  return op();
                }
                return lo(op);
              });
            });
          }(function(){});
        },
        hideMenu: function(){
          console.log("clicked to hide", this.get('clickedIndex'));
          this.set('clickedIndex', null);
          return this.set('editable', false);
        },
        toggleEditing: function(){
          var editable;
          editable = this.get('editable');
          return this.set('editable', !editable);
        },
        revert: function(){
          return alert("Changes Reverted!");
        },
        showModal: function(){
          var id;
          id = this.get('id');
          console.log("My id: ", id);
          return $("#" + id + "-modal").modal('show');
        }
      });
    },
    template: '#interactive-table',
    data: {
      editable: false,
      clickedIndex: null,
      cols: null,
      columnList: null,
      editTooltip: false,
      isEditingLine: function(index){
        var editable, clickedIndex;
        editable = this.get('editable');
        clickedIndex = this.get('clickedIndex');
        return editable && index === clickedIndex;
      }
    }
  });
  dataFromWebservice = [
    {
      siparisNo: "123",
      tarih: "10.06",
      sube: "orası-burası-şurası",
      urunSayisi: "5",
      tutar: "100"
    }, {
      siparisNo: "234",
      tarih: "11.06",
      sube: "orası-burası-şurası",
      urunSayisi: "2",
      tutar: "150"
    }, {
      siparisNo: "345",
      tarih: "12.06",
      sube: "orası-burası-şurası",
      urunSayisi: "10",
      tutar: "310"
    }, {
      siparisNo: "456",
      tarih: "13.06",
      sube: "orası-burası-şurası",
      urunSayisi: "3",
      tutar: "50"
    }
  ];
  decorateTableData = function(tableData){
    var i$, x$, len$, results$ = [];
    for (i$ = 0, len$ = tableData.length; i$ < len$; ++i$) {
      x$ = tableData[i$];
      results$.push([x$.tarih, x$.siparisNo, x$.sube, x$.urunSayisi, x$.tutar]);
    }
    return results$;
  };
  x = decorateTableData(dataFromWebservice);
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myTableData: x
    },
    components: {
      'interactive-table': InteractiveTable
    }
  });
  sleep = function(ms, f){
    return setTimeout(f, ms);
  };
  ractive.on('complete', function(){
    return function lo(op){
      console.log("x is: ", x[2][3]);
      return sleep(2000, function(){
        return lo(op);
      });
    }(function(){});
  });
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
