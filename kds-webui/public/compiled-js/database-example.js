(function(){
  var ref$, split, take, join, listsToObj, sum, PouchDB, Auth, a, sleep, db, InteractiveTable, satisListesi, ractive, generateEntryId, getEntryId, getMaterials, getSalesEntries;
  ref$ = require('prelude-ls'), split = ref$.split, take = ref$.take, join = ref$.join, listsToObj = ref$.listsToObj, sum = ref$.sum;
  PouchDB = require('pouchdb');
  Auth = require("pouchdb-auth");
  PouchDB.plugin(Auth);
  a = new PouchDB('_users');
  sleep = function(ms, f){
    return setTimeout(f, ms);
  };
  db = null;
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
        saveAndExit: function(){
          var index, line;
          index = this.get('clickedIndex');
          console.log("clicked to save and hide", index);
          line = this.get('tabledata')[index];
          db.put(line);
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
      tabledata: [],
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
  db = null;
  satisListesi = null;
  ractive = new Ractive({
    el: '#main-output',
    template: '#main-template',
    data: {
      myTableData: null,
      materials: [],
      newSales: {},
      salesEntries: [],
      salesToTable: function(salesData){
        var i$, x$, len$, results$ = [];
        for (i$ = 0, len$ = salesData.length; i$ < len$; ++i$) {
          x$ = salesData[i$];
          results$.push([x$.name, x$.date]);
        }
        return results$;
      }
    },
    components: {
      'interactive-table': InteractiveTable
    }
  });
  generateEntryId = function(userId){
    return function(){
      var timestamp;
      timestamp = new Date().getTime().toString(16);
      return userId + "-" + timestamp;
    };
  };
  getEntryId = generateEntryId(5);
  console.log("get entry id: ", getEntryId);
  ractive.on({
    updateTable: function(){
      console.log("updating satis listesi!", satisListesi);
      db.put(satisListesi, function(err, res){
        return console.log("satıs listesi (put): ", err, res);
      });
      return sleep(1000, function(){
        return console.log("satis-listesi: :: ", satisListesi);
      });
    },
    addSalesEntry: function(){
      var newSales;
      newSales = ractive.get('newSales');
      newSales.rel = "sales";
      newSales._id = getEntryId();
      console.log("putting new-sales: ", newSales);
      return db.put(newSales, function(err, res){
        if (!err) {
          return console.log("New sales entry is added successfully: ", res);
        }
      });
    }
  });
  db = new PouchDB('mydb');
  db.sync(remote, {
    live: true
  });
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
  /*
  db.info (err, res) ->
      console.log "info ::: ", x
  */
  db.query('getTitles/new-view', function(err, res){
    var e;
    try {
      if (err) {
        throw null;
      }
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
    } catch (e$) {
      e = e$;
      return console.log("can not get new view: ", err);
    }
  });
  getSalesEntries = function(){
    return db.query('get-by-type/get-sales', function(err, res){
      var e;
      try {
        if (err) {
          throw err;
        }
        console.log("got sales entries: ");
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
          console.log("sales entries: ", err, res);
          return ractive.set("salesEntries", (function(){
            var i$, x$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = res.rows).length; i$ < len$; ++i$) {
              x$ = ref$[i$];
              results$.push(x$.doc);
            }
            return results$;
          }()));
        });
      } catch (e$) {
        e = e$;
        return console.log("error: ", e);
      }
    });
  };
  getSalesEntries();
  db.changes({
    since: 'now',
    live: true
  }).on('change', function(change){
    console.log("change detected!", change);
    getMaterials();
    return getSalesEntries();
  });
}).call(this);
