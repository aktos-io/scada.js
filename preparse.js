var fs = require( 'fs' );
var path = require( 'path' );
var Ractive = require( 'ractive' );
var cheerio = require( 'cheerio' );

var content = fs.readFileSync( './public/index.html' ).toString();
var $ = cheerio.load(content);
var template = $('#app').html();
fs.writeFileSync( './public/ractive.html', template);

content = fs.readFileSync( './public/ractive.html' ).toString();
var parsed = Ractive.parse(content);
var parsedStr = JSON.stringify(parsed);

console.log("length: ", parsedStr.length);

var js = 'var preparsed = ' + parsedStr + ';'
fs.writeFileSync( './public/javascripts/preparsed.js', js );
