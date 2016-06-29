/*
###################################################################
This code can compile the every [component].html in given dirname
and it can take only component's scripts.
###################################################################
*/
(function(){
  var fs, path, cheerio, ref$, each, split, dirname, componentsHtml, componentsLs, listFiles, getFiles, compileHtmlFiles, compileLsFiles, filesInDir, htmlFiles, lsFiles;
  fs = require('fs');
  path = require('path');
  cheerio = require('cheerio');
  ref$ = require('prelude-ls'), each = ref$.each, split = ref$.split;
  dirname = __dirname;
  componentsHtml = 'components.html';
  componentsLs = 'components.ls';
  fs.writeFile(componentsLs, '\n');
  fs.writeFile(componentsHtml, '\n');
  listFiles = function(dir, files_){
    var files;
    files_ = files_ || [];
    files = fs.readdirSync(dir);
    return files;
  };
  getFiles = function(extension){
    var filteredFiles, i$, ref$, len$, i, file;
    filteredFiles = [];
    for (i$ = 0, len$ = (ref$ = filesInDir).length; i$ < len$; ++i$) {
      i = ref$[i$];
      file = i.split('.');
      if (file[1] === extension) {
        filteredFiles.push(file[0]);
      }
    }
    return filteredFiles;
  };
  compileHtmlFiles = function(files){
    var ignoreFiles, i$, len$, i, content, $, component, results$ = [];
    try {
      fs.unlink(componentsHtml);
    } catch (e$) {}
    ignoreFiles = ['components'];
    for (i$ = 0, len$ = files.length; i$ < len$; ++i$) {
      i = files[i$];
      if (in$(i, ignoreFiles)) {
        results$.push(console.log("Passing..."));
      } else {
        content = fs.readFileSync(dirname + ("/" + i + ".html")).toString();
        $ = cheerio.load(content);
        component = $("#" + (i + "")).wrap('<script>').parent().html();
        if (component !== null && component.length > 10) {
          fs.appendFile(componentsHtml, '\n');
          fs.appendFile(componentsHtml, component);
          results$.push(fs.appendFile(componentsHtml, '\n'));
        }
      }
    }
    return results$;
  };
  compileLsFiles = function(files){
    var ignoreFiles, i$, len$, i, content, component, results$ = [];
    try {
      fs.unlink(componentsLs);
    } catch (e$) {}
    ignoreFiles = ['compile-components', 'components'];
    for (i$ = 0, len$ = files.length; i$ < len$; ++i$) {
      i = files[i$];
      if (in$(i, ignoreFiles)) {
        results$.push(console.log("Passing..."));
      } else {
        content = fs.readFileSync(dirname + ("/" + i + ".ls")).toString();
        component = content.split("#END-OF-COMPONENT")[0];
        if (component !== null && component.length > 10) {
          fs.appendFile(componentsLs, '\n');
          fs.appendFile(componentsLs, component);
          results$.push(fs.appendFile(componentsLs, '\n'));
        }
      }
    }
    return results$;
  };
  filesInDir = listFiles(dirname);
  htmlFiles = getFiles('html');
  lsFiles = getFiles('ls');
  compileHtmlFiles(htmlFiles);
  compileLsFiles(lsFiles);
  function in$(x, xs){
    var i = -1, l = xs.length >>> 0;
    while (++i < l) if (x === xs[i]) return true;
    return false;
  }
}).call(this);
