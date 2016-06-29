(function(){
  var ref$, maximumBy, last, sortBy, split, take, join, listsToObj, sum, LineChart, myData, ractive;
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
}).call(this);
