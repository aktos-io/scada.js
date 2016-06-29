(function(){
  var ref$, split, take, join, listsToObj, sum, sleep, InteractiveTable, dataFromWebservice, decorateTableData, x, ractive;
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
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
}).call(this);
