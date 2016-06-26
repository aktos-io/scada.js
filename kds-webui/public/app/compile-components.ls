/*
###################################################################
This code can compile the every [component].html in given dirname
and it can take only component's scripts.
###################################################################
*/

fs = require \fs
path = require \path
cheerio = require \cheerio
{each, split} = require 'prelude-ls'

dirname = '/home/mesut/dev/kds/kds-webui/public/app'
#dirname = '/home/mesut/dev/livescript-file-read'
components-html = \components.html
components-ls = \components.ls

#Touch the files
fs.write-file components-ls, '\n'
fs.write-file components-html, '\n'

#List the files in the given directory.
list-files = (dir, files_) ->
    files_ = files_ || []
    files = fs.readdir-sync dir
    #console.log "Files : ", files
    files

#List the files whatever wanted extension
get-files = (extension) ->
    filtered-files = []
    for i in files-in-dir
        file = i.split '.'
        #console.log "html file is : ", html-file
        if file.1 is extension
            filtered-files.push file.0
    filtered-files

#Compile html files and write the components.html
compile-html-files = (files)->
    #Firstly, delete the file
    try
        fs.unlink components-html
    ignore-files = ['components']
    for i in files
        if i in ignore-files
            console.log "Passing..."
        else
            content = fs.read-file-sync dirname+"/#i.html" .to-string!
            #console.log "Content is : ", content
            $ = cheerio.load content
            #component = $ "#"+"#{i}" .html!
            component = $ "#"+"#{i}" .wrap \<script> .parent! .html!

            #console.log "-"*15
            #console.log "COMPONENT WITH TAGS: ", component
            #console.log "-"*15
            if component isnt null and component.length > 10
                fs.append-file components-html, '\n'
                fs.append-file components-html, component
                fs.append-file components-html, '\n'

#Compile ls files and write the components.ls
compile-ls-files = (files) ->
    #Firstly, delete the file
    try
        fs.unlink components-ls
    ignore-files = ['compile-components', 'components']
    for i in files
        if i in ignore-files
            console.log "Passing..."
        else
            content = fs.read-file-sync dirname+"/#i.ls" .to-string!
            component = content.split("\#END-OF-COMPONENT").0
            if component isnt null and component.length > 10
                fs.append-file components-ls, '\n'
                fs.append-file components-ls, component
                fs.append-file components-ls, '\n'

files-in-dir = list-files dirname

html-files = get-files \html
ls-files = get-files \ls
#console.log "HTML : ", html-files
#console.log "LS : ", ls-files
compile-html-files html-files
compile-ls-files ls-files
