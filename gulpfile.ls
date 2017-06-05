argv = require 'yargs' .argv

project = argv.app or \example
app = argv.webapp or project
only-compile = yes if argv.optimize is true

console.log "------------------------------------------"
console.log "App\t: #{project}"
console.log "Webapp\t: #{app}"
if only-compile
    console.log "------------------------------------------"
    console.log " Gulp is running only once for optimization..."
console.log "------------------------------------------"

require! <[ watchify gulp browserify glob path fs globby touch ]>
require! 'prelude-ls': {union, join, keys, map, unique}
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-pug': pug
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'gulp-uglify': uglify
require! './src/lib/aea': {sleep, pack}
require! './src/lib/aea/ractive-preparserify': {
    ractive-preparserify
    preparserify-dep-list
}
require! './src/lib/aea/browserify-optimize-js'
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-cached': cache
require! 'gulp-sourcemaps': sourcemaps
require! 'browserify-livescript'
require! 'run-sequence'
require! 'through2':through
require! 'optimize-js'
require! 'gulp-if-else': if-else
require! 'gulp-rename': rename

# Build Settings
notification-enabled = yes

# Project Folder Structure
paths =
    vendor-folder: "#{__dirname}/vendor"
    build-folder: "#{__dirname}/build"
    client-src: "#{__dirname}/src/client"
    lib-src: "#{__dirname}/src/lib"
    client-webapps: "#{__dirname}/apps/#{project}/webapps"

paths.client-public = "#{paths.build-folder}/#{project}/#{app}"
paths.components-src = "#{paths.client-src}/components"



notifier.notify {title: "ScadaJS" message: "Project #{project}:#{app} started!"}

on-error = (source, msg) ->
    msg = try
        msg.to-string!
    catch
        "unknown message: #{e}"
    console-msg = "GULP ERROR: #{source} : #{msg}"
    notifier.notify {title: console-msg, message: msg} if notification-enabled
    console.log console-msg

log-info = (source, msg) ->
    msg = try
        msg.to-string!
    catch
        "unknown message: #{e}"
    console-msg = "GULP INFO: #{source} : #{msg}"
    notifier.notify {title: "GULP.#{source}", message: msg} if notification-enabled
    console.log console-msg

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


pug-entry-files = glob.sync "#{paths.client-webapps}/**/#{app}/index.pug"
html-entry-files = glob.sync "#{paths.client-webapps}/#{app}/index.html"
ls-entry-files = glob.sync "#{paths.client-webapps}/**/#{app}/app.{ls,js}"

for-css =
    "#{paths.vendor-folder}/**/*.css"
    "#{paths.client-src}/**/*.css"
    "#{paths.client-webapps}/**/*.css"

for-preparserify-workaround =
    "#{paths.client-webapps}/#{app}/**/*.html"
    "#{paths.client-src}/**/*.html"
    "#{paths.client-webapps}/#{app}/**/*.pug"
    "#{paths.client-src}/**/*.pug"


# Organize Tasks
gulp.task \default, ->
    if argv.clean is true
        console.log "Clearing build directory..."
        deleteFolderRecursive paths.build-folder
        return

    do function run-all
        gulp.start do
            \browserify
            \html
            \vendor
            \vendor-css
            \assets
            \pug
            \preparserify-workaround

    if only-compile
        return

    watch pug-entry-files, ->
        gulp.start \pug

    watch html-entry-files, ->
        gulp.start \html

    watch for-css, (event) ->
        gulp.start <[ vendor-css ]>

    watch "#{paths.vendor-folder}/**", (event) ->
        gulp.start <[ vendor ]>


    for-browserify =
        "#{paths.client-webapps}/#{app}/**/*.ls"
        "#{paths.client-src}/**/*.ls"
        "#{paths.lib-src}/**/*.ls"
        "#{paths.lib-src}/**/*.js"

    watch for-browserify, ->
        gulp.start \browserify

    watch for-preparserify-workaround, ->
        gulp.start \preparserify-workaround


# Copy js and html files as is
#gulp.task \copy-js, ->
#    gulp.src "#{paths.client-src}/**/*.js", {base: paths.client-src}
#        .pipe gulp.dest paths.client-public


gulp.task \html, ->
    gulp.src html-entry-files
        #.pipe rename basename: app
        .pipe flatten!
        .pipe gulp.dest paths.client-public


browserify-cache = {}
bundler = browserify do
    entries: ls-entry-files
    debug: true
    paths:
        paths.components-src
        paths.lib-src
        paths.client-webapps
    extensions: <[ .ls ]>
    cache: browserify-cache
    package-cache: {}
    plugin:
        watchify unless only-compile
        ...

bundler.transform browserify-livescript
bundler.transform ractive-preparserify
bundler.transform browserify-optimize-js

first-browserify-done = no

function bundle
    bundler
        .bundle!
        .on \error, (err) ->
            msg = try
                err.message
            catch
                err
            on-error \browserify, msg
            @emit \end
        .pipe source "#{project}/#{app}/app.js"
        .pipe buffer!
        #.pipe sourcemaps.init {+load-maps, +large-files}
        .pipe if-else only-compile, uglify
        #.pipe rename basename: 'app'
        #.pipe sourcemaps.write '.'
        .pipe gulp.dest paths.build-folder
        .pipe tap (file) ->
            log-info \browserify, "Browserify finished (#{project}:#{app})"
            #console.log "browserify cache: ", pack keys browserify-cache
            console.log "------------------------------------------"
            first-browserify-done := yes

gulp.task \browserify, ->
    bundle!


# Concatenate vendor javascript files into public/js/vendor.js
gulp.task \vendor, ->
    files = glob.sync "./vendor/**/*.js"
    gulp.src files
        .pipe cat "vendor.js"
        .pipe uglify!
        .pipe through.obj (file, enc, cb) ->
            contents = file.contents.to-string!
            optimized = optimize-js contents
            optimized = "//optimized by optimize.js\n" + optimized
            file.contents = new Buffer optimized

            cb null, file
        .pipe gulp.dest "#{paths.client-public}/js"

# Concatenate vendor css files into public/css/vendor.css
gulp.task \vendor-css, ->
    gulp.src for-css
        .pipe cat "vendor.css"
        .pipe gulp.dest "#{paths.client-public}/css"

# Copy assets into the public directory as is
gulp.task \assets, ->
    gulp.src "#{paths.client-src}/assets/**", {base: "#{paths.client-src}/assets"}
        .pipe gulp.dest paths.client-public

# Compile pug files in paths.client-src to the paths.client-tmp folder
gulp.task \pug ->
    gulp.src pug-entry-files
        .pipe tap (file) ->
            #console.log "pug: compiling file: ", path.basename file.path
        .pipe pug do
            pretty: yes
            locals:
                app: app
        .on \error, (err) ->
            on-error \pug, err
            @emit \end
        #.pipe rename basename: app
        .pipe flatten!
        .pipe gulp.dest paths.client-public

# FIXME: This is a workaround before ractive-preparserify
# will handle this process all by itself.
debounce = {}
gulp.task \preparserify-workaround ->
    gulp.src for-preparserify-workaround
        .pipe cache 'preparserify-workaround-cache'
        .pipe tap (file) ->
            #console.log "preparserify-workaround: invalidating: ", file.path
            unless first-browserify-done
                #console.log "DEBUG: Ractive Preparserify: skipping because first browserify is not done yet"
                return
            rel = preparserify-dep-list[file.path]
            if typeof! rel is \Array
                for js-file in unique rel
                    console.log "INFO: Preparserify workaround: triggering for #{path.basename js-file}"
                    try
                        clear-timeout debounce[js-file]
                        console.log "Preventing debounce for #{js-file}"
                    catch
                        console.log "...no need to prevent debounce for #{js-file}"

                    debounce[js-file] = sleep 100ms, ->
                        touch.sync js-file
                        delete debounce[js-file]
            else
                log-info 'preparserify', "related documents should be an array: "
                console.log pack rel
