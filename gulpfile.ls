require! 'yargs':{argv}

if argv.webapp
    webapp = that
else
    console.log "ERROR: You should pass a --webapp=mywebapp parameter. Exiting."
    process.exit!

webapp = argv.webapp
optimize-for-production = yes if argv.production is true


require! <[ watchify gulp browserify glob path fs globby touch ]>
require! 'prelude-ls': {union, join, keys, map, unique, empty}
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-pug': pug
require! './templates/filters': {pug-filters}
require! 'buble'
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'gulp-uglify-es': {default: uglify}
require! './lib/aea': {sleep, pack}
require! './lib/aea/ractive-preparserify': {
    ractive-preparserify
    preparserify-dep-list
}
require! './lib/aea/browserify-optimize-js'
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-cached': cache
require! 'gulp-sourcemaps': sourcemaps
require! 'browserify-livescript'
require! 'through2':through
require! 'optimize-js'
require! 'gulp-if-else': if-else
require! 'gulp-rename': rename
require! 'gulp-util': gutil
require! 'gulp-git': git
require! 'gulp-cssimport': cssimport
require! 'event-stream': es

get-version = (callback) ->
    err, stdout <- git.exec args: 'describe --tags --dirty --long'
    throw if err
    callback stdout

console.log "------------------------------------------"
#console.log "App\t: #{app}"
console.log "Webapp\t: #{webapp}"

if optimize-for-production
    console.log "------------------------------------------"
    console.log " Gulp will optimize the application for production."
console.log "------------------------------------------"

# Build Settings
notification-enabled = yes

# Project Folder Structure
paths =
    vendor-folder: "#{__dirname}/vendor"
    vendor2-folder: "#{__dirname}/vendor2"
    build-folder: "#{__dirname}/build"
    lib-src: "#{__dirname}/lib"
    client-webapps: "#{__dirname}/../webapps"
    client-root: "#{__dirname}/.."

paths.client-public = "#{paths.build-folder}/#{webapp}"
paths.components-src = "#{__dirname}/components"



notifier.notify {title: "ScadaJS" message: "Webapp \"#{webapp}\" started!"}

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


pug-entry-files = glob.sync "#{paths.client-webapps}/#{webapp}/index.pug"
html-entry-files = glob.sync "#{paths.client-webapps}/#{webapp}/index.html"
app-entry-files = glob.sync "#{paths.client-webapps}/#{webapp}/app*.{ls,js}"


for-css =
    "#{paths.vendor-folder}/**/*.css"
    "!#{paths.vendor-folder}/**/__tmp__/**"

for-js =
    "#{paths.vendor-folder}/**/*.js"
    "!#{paths.vendor-folder}/**/__tmp__/**"
    "!#{paths.vendor-folder}/**/assets/**"

for-css2 =
    "#{paths.vendor2-folder}/**/*.css"
    "!#{paths.vendor2-folder}/**/__tmp__/**"
    "#{paths.components-src}/**/*.css"
    "#{paths.client-webapps}/**/*.css"

for-js2 =
    "#{paths.vendor2-folder}/**/*.js"
    "!#{paths.vendor2-folder}/**/__tmp__/**"
    "!#{paths.vendor2-folder}/**/assets/**"

# changes on these files will invalidate browserify cache
for-preparserify-workaround =
    "#{paths.client-webapps}/#{webapp}/**/*.pug"
    "#{paths.client-webapps}/#{webapp}/**/*.html"
    "#{paths.components-src}/**/*.pug"
    "#{paths.components-src}/**/*.html"

for-assets =
    "#{paths.components-src}/**/assets/**"
    "#{paths.client-root}/assets/**"
    "#{paths.client-webapps}/**/assets/**"
    "#{__dirname}/assets/**"

    # assets folder in vendor
    "#{paths.vendor-folder}/**/assets/**"
    "!#{paths.vendor-folder}/**/__tmp__/**"
    "!#{paths.vendor-folder}/**/tmp-*/**"

    # assets folder in vendor2
    "#{paths.vendor2-folder}/**/assets/**"
    "!#{paths.vendor2-folder}/**/__tmp__/**"
    "!#{paths.vendor2-folder}/**/tmp-*/**"

for-browserify =
    # livescript files in webapp folder
    "#{paths.client-webapps}/#{webapp}/**/*.ls"
    "#{paths.client-webapps}/#{webapp}/**/*.js"

    # files in components
    "#{paths.components-src}/**/*.ls"
    "#{paths.components-src}/**/*.js"

    # files in lib
    "#{paths.lib-src}/**/*.ls"
    "#{paths.lib-src}/**/*.js"

    # files in project_root/lib
    "#{paths.client-root}/lib/**/*.ls"
    "#{paths.client-root}/lib/**/*.js"


# Organize Tasks
gulp.task \default, ->
    do function run-all
        gulp.start do
            \browserify
            \html
            \vendor-js
            \vendor-css
            \vendor2-js
            \vendor2-css
            \assets
            \pug
            \preparserify-workaround

    if optimize-for-production
        return

    watch pug-entry-files, ->
        gulp.start \pug

    watch html-entry-files, ->
        gulp.start \html

    watch for-css, (event) ->
        gulp.start <[ vendor-css ]>

    watch for-js, (event) ->
        gulp.start <[ vendor-js ]>

    watch for-css2, (event) ->
        gulp.start <[ vendor2-css ]>

    watch for-js2, (event) ->
        gulp.start <[ vendor2-js ]>

    watch for-browserify, ->
        gulp.start \browserify

    watch for-preparserify-workaround, ->
        gulp.start \preparserify-workaround

    watch for-assets, ->
        gulp.start \assets


# Copy js and html files as is
#gulp.task \copy-js, ->
#    gulp.src "#{paths.client-src}/**/*.js", {base: paths.client-src}
#        .pipe gulp.dest paths.client-public


gulp.task \html, ->
    gulp.src html-entry-files
        #.pipe rename basename: app
        .pipe flatten!
        .pipe gulp.dest paths.client-public

my-uglify = (x) ->
    uglify {-mangle}, x
    .on \error, gutil.log

my-buble = (input) ->
    es5 = buble.transform input
    es5.code

browserify-cache = {}

get-bundler = (entry) ->
    b = browserify do
        entries: [entry]
        debug: true
        paths:
            __dirname
            paths.lib-src
            paths.client-webapps
            "#{__dirname}/node_modules"
            "#{__dirname}/.."
        extensions: <[ .ls ]>
        cache: browserify-cache
        package-cache: {}
        plugin:
            watchify unless optimize-for-production

    b
        ..transform browserify-livescript     # MUST be before ractive-preparserify
        ..transform (file) ->
            through (buf, enc, next) !->
                content = buf.to-string \utf8
                try
                    es5 = my-buble content
                    @push es5
                    next!
                catch
                    console.log "This is buble error: ", e
                    @emit 'error', e

        ..transform ractive-preparserify
        ..transform browserify-optimize-js

files = app-entry-files
b-count = files.length

gulp.task \browserify, ->
    tasks = for let file in files
        filebase = file.split(/[\\/]/).pop! .replace /\.[a-z]+/, '.js'
        console.log "creating bundler task for #{filebase}"
        get-bundler file
            .bundle!
            .on \error, (err) ->
                msg = try
                    err.message
                catch
                    err
                on-error \browserify, msg
                @emit \end

            .pipe source filebase
            .pipe buffer!
            #.pipe sourcemaps.init {+load-maps, +large-files}

            .pipe if-else optimize-for-production, my-uglify

            #.pipe rename basename: 'app'
            #.pipe sourcemaps.write '.'
            .pipe gulp.dest "#{paths.build-folder}/#{webapp}/js"
            .pipe tap (file) ->
                log-info \browserify, "Browserify finished (#{webapp}/js/#{filebase})"
                #console.log "browserify cache: ", pack keys browserify-cache
                b-count-- if b-count > 0
                version <~ get-version
                console.log "version: #{version}"
                console.log "------------------------------------------"

    return es.merge.apply null, tasks

# Concatenate vendor javascript files into public/js/vendor.js
compile-js = (watchlist, output) ->
    gulp.src watchlist
        .pipe cat output
        .pipe if-else optimize-for-production, my-uglify

        .pipe through.obj (file, enc, cb) ->
            contents = file.contents.to-string!
            es5 = my-buble contents
            file.contents = new Buffer es5
            cb null, file

        .pipe through.obj (file, enc, cb) ->
            contents = file.contents.to-string!
            optimized = optimize-js contents
            file.contents = new Buffer optimized
            cb null, file

        .pipe gulp.dest "#{paths.client-public}/js"


compile-css = (watchlist, output) ->
    gulp.src watchlist
        .pipe cssimport {includePaths: ['node_modules']}
        .pipe cat output

        # themes are searched in ../themes path, so do not save css in root
        # folder
        .pipe gulp.dest "#{paths.client-public}/css"

gulp.task \vendor-js, ->
    compile-js for-js, "vendor.js"

# Concatenate vendor css files into public/css/vendor.css
gulp.task \vendor-css, ->
    compile-css for-css, "vendor.css"


gulp.task \vendor2-js, ->
    compile-js for-js2, "vendor2.js"

# Concatenate vendor css files into public/css/vendor.css
gulp.task \vendor2-css, ->
    compile-css for-css2, "vendor2.css"

# Copy assets into the public directory as is
# search for a folder named "assets", copy and paste its contents into
# build folder.
sep = if /^win/.test process.platform => '\\' else '/'

gulp.task \assets, ->
    gulp.src for-assets
        .pipe rename (path) ->
            path-parts = path.dirname.split sep
            parts = []
            found-assets = no
            for i in path-parts
                if i isnt \assets
                    unless found-assets
                        continue
                else
                    if not found-assets
                        found-assets = yes
                        continue
                parts.push i
            _tmp = join sep, parts
            path.dirname = _tmp if found-assets

        # do not send to a subfolder, assets should be in the
        # root folder.
        .pipe gulp.dest paths.client-public


# Compile pug files in paths.client-src to the paths.client-tmp folder
gulp.task \pug ->
    gulp.src pug-entry-files
        .pipe tap (file) ->
            #console.log "pug: compiling file: ", path.basename file.path
        .pipe pug do
            pretty: yes
            locals:
                app: 'ScadaJS'
            filters: pug-filters
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
            #console.log "DEBUG: preparserify-workaround: invalidating: ", file.path
            if b-count > 0
                #console.log "DEBUG: Ractive Preparserify: skipping because first browserify is not done yet"
                return
            rel = preparserify-dep-list[file.path]
            rel = [rel] unless typeof! rel is \Array
            rel = unique [.. for rel when ..] # filter out undefined and duplicate files

            unless empty rel
                for js-file in rel
                    #console.log "INFO: Preparserify workaround: triggering for #{path.basename js-file}"
                    try
                        clear-timeout debounce[js-file]
                        console.log "INFO: Preventing debounce for #{js-file}"
                    catch
                        console.log "INFO: ...no need to prevent debounce for #{js-file}"

                    debounce[js-file] = sleep 100ms, ->
                        touch.sync js-file
                        delete debounce[js-file]
