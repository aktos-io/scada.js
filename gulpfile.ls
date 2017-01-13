argv = require 'yargs' .argv

project = argv.project or \aktos
app = argv.app or project
console.log "------------------------------------------"
console.log "Project\t: #{project}"
console.log "App\t: #{app}"
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
    ractive-preparserify, preparserify-dep-list
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

paths = {}
paths.vendor-folder = "#{__dirname}/vendor"
paths.build-folder = "#{__dirname}/build"
paths.client-public = "#{paths.build-folder}/public"
paths.client-src = "#{__dirname}/src/client"
paths.client-apps = "#{paths.client-public}"
paths.client-webapps = "#{__dirname}/apps/#{project}/webapps"
paths.lib-src = "#{__dirname}/src/lib"
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

only-compile = yes if argv.compile is true

pug-entry-files = glob.sync "#{paths.client-webapps}/**/#{app}/index.pug"
ls-entry-files = glob.sync "#{paths.client-webapps}/**/#{app}/index.{ls,js}"
html-entry-files = glob.sync "#{paths.client-webapps}/#{app}/index.html"

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
        console.log "Gulp will compile only once..."
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
gulp.task \copy-js, ->
    gulp.src "#{paths.client-src}/**/*.js", {base: paths.client-src}
        .pipe gulp.dest paths.client-apps

gulp.task \html, ->
    gulp.src html-entry-files
        .pipe rename basename: app
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
        .pipe source "public/#{app}.js"
        .pipe buffer!
        #.pipe sourcemaps.init {+load-maps, +large-files}
        .pipe if-else only-compile, uglify
        .pipe rename basename: app
        #.pipe sourcemaps.write '.'
        .pipe gulp.dest './build'
        .pipe tap (file) ->
            log-info \browserify, "Browserify finished"
            #console.log "browserify cache: ", pack keys browserify-cache


gulp.task \browserify, -> run-sequence \copy-js, ->
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
        .pipe gulp.dest "#{paths.client-apps}/js"

# Concatenate vendor css files into public/css/vendor.css
gulp.task \vendor-css, ->
    gulp.src for-css
        .pipe cat "vendor.css"
        .pipe gulp.dest "#{paths.client-apps}/css"

# Copy assets into the public directory as is
gulp.task \assets, ->
    gulp.src "#{paths.client-src}/assets/**/*", {base: "#{paths.client-src}/assets"}
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
        .pipe rename basename: app
        .pipe flatten!
        .pipe gulp.dest paths.client-public

# FIXME: This is a workaround before we can accurately detect the dependencies of a
# javascript files that uses a Ractive Template. In the end, ractive-preparserify
# should handle this process all by itself.
debounce = {}
first-debounce-time = 15_000ms
skip-first-time = yes
gulp.task \preparserify-workaround ->
    gulp.src for-preparserify-workaround
        .pipe cache 'preparserify-workaround-cache'
        .pipe tap (file) ->
            #console.log "preparserify-workaround: ", file.path
            rel = preparserify-dep-list[file.path]
            if typeof! rel is \Array
                for js-file in unique rel
                    #console.log "DEBUG: as #{file.path} changed: "
                    try
                        throw unless debounce[js-file]
                        clear-timeout debounce[js-file]
                        console.log "INFO: absorbed debounce for #{path.basename js-file}..."
                    #console.log "we need to invalidate: ", js-file
                    debounce[js-file] = sleep (first-debounce-time + 100ms), ->
                        if skip-first-time
                            skip-first-time := no
                            return
                        console.log "triggering for #{path.basename js-file} debounce-time: #{first-debounce-time}"
                        first-debounce-time := 0
                        touch.sync js-file
