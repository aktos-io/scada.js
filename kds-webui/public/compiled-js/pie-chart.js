(function(){
  var ref$, split, take, join, listsToObj, sum, sort, sleep, PieChart, simulateData, ractive;
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
}).call(this);
