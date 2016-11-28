exports.preparseRactive = function () {
var fs = require( 'fs' );
var path = require( 'path' );
var Ractive = require( 'ractive' );
var cheerio = require( 'cheerio' );

var targetDir = './build/public'

var sourceHtml = targetDir + '/demeter.html';
var preparsedJs = targetDir + '/demeter-preparsed.js'

var content = fs.readFileSync( sourceHtml ).toString();
var $ = cheerio.load(content);
var template = $('#main-template').html();

/*
var strippedHtml = targetDir + '/demeter-main-template.html';
fs.writeFileSync( strippedHtml, template);
template = fs.readFileSync( strippedHtml ).toString();
*/

var parsed = Ractive.parse(template);
var parsedStr = JSON.stringify(parsed);

console.log("length: ", parsedStr.length);

var js = 'var mainTemplate = ' + parsedStr + ';'
fs.writeFileSync( preparsedJs, js );
}
