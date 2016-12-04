argv = require 'yargs' .argv

project = argv.project or \aktos
console.log "------------------------------------------"
console.log "Compiling for project: #{project}"
console.log "------------------------------------------"

require! <[ watchify gulp browserify glob path fs globby ]>
require! 'prelude-ls': {union, join, keys}
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-pug': pug
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'gulp-uglify': uglify
require! './src/lib/aea': {sleep}
require! './src/lib/aea/ractive-preparserify'
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-cached': cache
require! 'gulp-sourcemaps': sourcemaps
require! 'browserify-livescript'

# Build Settings
notification-enabled = yes

# Project Folder Structure

paths = {}
paths.vendor-folder = "#{__dirname}/vendor"
paths.build-folder = "#{__dirname}/build"
paths.client-public = "#{paths.build-folder}/public"
paths.client-src = "#{__dirname}/src/client"
paths.client-apps = "#{paths.client-public}"
paths.client-webapps = "#{__dirname}/apps/#{project}/webapps"
paths.lib-src = "#{__dirname}/src/lib"
paths.components-src = "#{paths.client-src}/components"


notifier.notify {title: "aktos-scada2" message: "Project #{project} started!"}

on-error = (source, err) ->
    msg = "GULP ERROR: #{source} :: #{err?.to-string!}"
    notifier.notify {title: "GULP.#{source}", message: msg} if notification-enabled
    console.log msg

log-info = (source, msg) ->
    console-msg = "GULP INFO: #{source} : #{msg}"
    notifier.notify {title: "GULP.#{source}", message: msg} if notification-enabled
    console.log console-msg

is-module-index = (base, file) ->
    if base is path.dirname file
        #console.log "this is a simple file: ", file
        return true

    [filename, ext] = path.basename file .split '.'

    if filename is "#{path.basename path.dirname file}"
        #console.log "this is custom module: ", file
        return true

    if file is "#{path.dirname file}/index.#{ext}"
        #console.log "this is a standart module", file
        return true

    #console.log "not a module index: #{file} (filename: #{filename}, ext: #{ext})"
    return false

deleteFolderRecursive = (path) ->
    if fs.existsSync(path)
        fs.readdirSync(path).forEach (file,index) ->
            curPath = path + "/" + file
            if(fs.lstatSync(curPath).isDirectory())  # recurse
              deleteFolderRecursive(curPath)
            else
                # delete file
                fs.unlinkSync(curPath)
        fs.rmdirSync(path)

only-compile = yes if argv.compile is true

# Organize Tasks
gulp.task \default, ->
    if argv.clean is true
        console.log "Clearing build directory..."
        deleteFolderRecursive paths.build-folder
        return

    do function run-all
        gulp.start <[ browserify html vendor vendor-css assets pug ]>

    if only-compile
        console.log "Gulp will compile only once..."
        return

    for-pug =
        "#{paths.client-webapps}/**/#{project}.pug"

    watch for-pug, ->
        gulp.start \pug

    watch "#{paths.vendor-folder}/**", (event) ->
        gulp.start <[ vendor vendor-css ]>


    for-browserify =
        "#{paths.client-webapps}/**/*.ls"
        "#{paths.client-webapps}/**/*.pug"
        "#{paths.client-src}/**/*.pug"
        "#{paths.client-src}/**/*.ls"

    watch for-browserify, ->
        gulp.start \browserify

# Copy js and html files as is
gulp.task \copy-js, ->
    gulp.src "#{paths.client-src}/**/*.js", {base: paths.client-src}
        .pipe gulp.dest paths.client-apps

gulp.task \html, ->
    base = "#{paths.client-webapps}"
    gulp.src "#{base}/**/*.html", {base: base}
        .pipe gulp.dest "#{paths.client-public}"


files = glob.sync "#{paths.client-webapps}/**/#{project}/#{project}.ls"

bundler = browserify do
    entries: files
    debug: true
    paths:
        paths.components-src
        paths.lib-src
        paths.client-webapps
    extensions: <[ .ls ]>
    cache: {}
    package-cache: {}
    plugin: [watchify unless only-compile]

bundler.transform \browserify-livescript
bundler.transform ractive-preparserify

function bundle
    bundler
        .bundle!
        .on \error, (err) ->
            on-error \browserify, err
            console.log "err stack: ", err.stack
            @emit \end
        .pipe source "public/#{project}.js"
        .pipe buffer!
        .pipe sourcemaps.init {+load-maps, +large-files}
        .pipe sourcemaps.write '.'
        .pipe gulp.dest './build'
        .pipe tap (file) ->
            log-info \browserify, "Browserify finished"

gulp.task \browserify, <[ copy-js ]>, !->
    bundle!

# Concatenate vendor javascript files into public/js/vendor.js
gulp.task \vendor, ->
    files = glob.sync "./vendor/**/*.js"
    gulp.src files
        .pipe tap (file) ->
            #console.log "VENDOR: ", file.path
        .pipe cat "vendor.js"
        .pipe gulp.dest "#{paths.client-apps}/js"

# Concatenate vendor css files into public/css/vendor.css
gulp.task \vendor-css, ->
    gulp.src "#{paths.vendor-folder}/**/*.css"
        .pipe cat "vendor.css"
        .pipe gulp.dest "#{paths.client-apps}/css"

# Copy assets into the public directory as is
gulp.task \assets, ->
    gulp.src "#{paths.client-src}/assets/**/*", {base: "#{paths.client-src}/assets"}
        .pipe gulp.dest paths.client-public

# Compile pug files in paths.client-src to the paths.client-tmp folder
gulp.task \pug ->
    base = "#{paths.client-webapps}"
    files = glob.sync "#{base}/**/#{project}.pug"
    gulp.src files
        .pipe tap (file) ->
            #console.log "pug: compiling file: ", path.basename file.path
        .pipe pug {pretty: yes}
        .on \error, (err) ->
            on-error \pug, err
            @emit \end
        .pipe flatten!
        .pipe gulp.dest paths.client-apps
