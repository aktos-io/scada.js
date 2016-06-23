/*
This code can compile the every [component].html in given dirname
and it can take only component's scripts.
*/

fs = require \fs
path = require \path
cheerio = require \cheerio
{each, split} = require 'prelude-ls'

dirname = '/home/mesut/dev/kds/kds-webui/public/app'
#dirname = '/home/mesut/dev/livescript-file-read/'
components-file = \components.html

get-files = (dir, files_) ->
    files_ = files_ || []
    files = fs.readdir-sync dir
    #console.log "Files : ", files
    files

files-in-dir = get-files dirname

html-files = []
for i in files-in-dir
    html-file = i.split '.'
    #console.log "html file is : ", html-file
    if html-file.1 is 'html'
        html-files.push html-file.0

console.log "HTML : ", html-files

fs.unlink components-file

for i in html-files
    content = fs.read-file-sync dirname+"/#i.html" .to-string!
    #console.log "Content is : ", content
    $ = cheerio.load content
    #component = $ "#"+"#{i}" .html!
    component = $ "#"+"#{i}" .wrap \<script> .parent! .html!

    console.log "-"*15
    console.log "COMPONENT WITH TAGS: ", component
    console.log "-"*15
    if component isnt null and component.length > 10
        fs.append-file components-file, '\n'
        fs.append-file components-file, component
        fs.append-file components-file, '\n'

        
