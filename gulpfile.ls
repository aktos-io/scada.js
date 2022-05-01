usage = '''

HELP: 

--webapp mywebapp           : Expect to find webapp in ../webapps/mywebapp 
--enable-version-polling    : Automatically trigger versionify transform upon git commit. 
--production                : Make production environment optimizations. 
--debug                     : Turns on the debugging messages and facilities.

--usage                      : Displays this message.

Hint: "export APP=mywebapp" before using Makefile.

'''

/*******************************************************

Helpful documents for writing Gulpfile:
-----------------------------------------

* Writing Gulp transforms: https://gist.github.com/CITguy/079c631ac5f181939e08
* Browserify related: 
    * https://stackoverflow.com/q/63151235/1952991

*******************************************************/
require! 'yargs':{argv}

DEBUG = argv.debug
if DEBUG
    console.log " ***************************** "
    console.log " ***** DEBUG MODE IS ON. ***** "
    console.log " ***************************** "


if typeof! argv.webapp is \String
    webapp = argv.webapp
else
    console.log "ERROR: Missing \"--webapp mywebapp\" parameter."
    console.log usage 
    process.exit!

if argv.usage 
    console.log usage 
    process.exit(30)

optimize-for-production = yes if argv.production is true

require! <[ 
    watchify 
    gulp 
    browserify 
    glob 
    path 
    fs  
    touch
    buble 
    through 
    ]>
require! 'prelude-ls': {union, join, keys, map, unique, empty, round}
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-pug': pug
require! './templates/filters': {pug-filters}
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'gulp-terser': terser
require! './lib/aea': {sleep, pack}
require! './lib/aea/ractive-preparserify': {ractive-preparserify}
require! './lib/aea/browserify-optimize-js'
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-sourcemaps': sourcemaps
require! 'livescript': lsc
require! 'through2':through2
require! 'optimize-js'
require! 'gulp-if-else': if-else
require! 'gulp-rename': rename
require! 'gulp-git': git
require! 'gulp-cssimport': cssimport
require! 'fancy-log': log 


console.log "------------------------------------------"
#console.log "App\t: #{app}"
log "Webapp\t: #{webapp}"

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
    release-folder: "#{__dirname}/release"
    lib-src: "#{__dirname}/lib"
    client-webapps: "#{__dirname}/../webapps"
    client-root: "#{__dirname}/.."

paths.client-public = if optimize-for-production
    "#{paths.release-folder}/#{webapp}"
else
    "#{paths.build-folder}/#{webapp}"
paths.components-src = "#{__dirname}/components"

notifier.notify {title: "ScadaJS" message: "Webapp \"#{webapp}\" started!"}

on-error = (source, msg) ->
    msg = try
        msg.to-string!
    catch
        "unknown error message: #{msg}" 
    console-msg = "#{source} : #{msg}"
    notifier.notify {title: console-msg, message: msg} if notification-enabled
    log.error console-msg

log-info = (source, msg, opts={}) ->
    msg = try
        msg.to-string!
    catch
        "unknown message: #{e}"
    console-msg = "#{source} : #{msg}"
    notifier.notify {title: "GULP.#{source}", message: msg} if notification-enabled
    unless opts.noConsole
        log console-msg

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

my-uglify = (x) ->
    # mangle: shutterstock/rickshaw/issues/52#issuecomment-313836636
    # keep_fnames: aktos-io/scada.js#172
    terser {-mangle, +keep_fnames} x
    .on \error, log

round-ms = (ms) -> 
    # rounds milliseconds to seconds with 1 decimal point
    ms / 100 |> round |> (/10)

my-buble = (input) ->
    try 
        es5 = buble.transform input, {
              transforms: {
                classes: true
                asyncAwait: false
                forOf: false
              }
        }
    catch 
        throw Error e 
    return es5.code

livescript-transform = (file) ->
    unless /.*\.ls$/.test(file)
        return through2!
        
    contents = ''
    write = (chunk, enc, next) !->
        contents += chunk.to-string \utf-8
        next!

    flush = (cb) -> 
        #console.log "lsc file contents:", contents
        try
            filename = file.replace(/^.*[\\\/]/, '')
            js = lsc.compile contents, {+bare, -header, map: 'embedded', filename}
            @push js.code
            cb!
        catch
            log "Livescript compile error: ", e
            @emit 'error', e

    return through2.obj write, flush 

get-version = (path, callback) ->
    if typeof! path is \Function
        callback = path
        path = undefined
    err, stdout <- git.exec {args: 'describe --always --dirty', +quiet, cwd: path}
    [commit, dirtiness] = stdout.split /[-\n]/
    err, stdout <- git.exec {args: 'rev-list --count HEAD', +quiet, cwd: path}
    count = +stdout
    callback {commit, dirty: (dirtiness is \dirty), count}

versionify = (file) -> 
    unless /app-version\.json$/.test(file)
        return through!

    write = (chunk) !->

    end = -> 
        version <~ get-version paths.client-root
        @queue "module.exports = #{JSON.stringify version}"
        @queue null 
    return through write, end

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
        cache: {} # required for watchify 
        package-cache: {} # required for watchify 
        fullPaths: yes 
        plugin:
            watchify unless optimize-for-production

    b
        ..transform livescript-transform
        ..transform ractive-preparserify
        ..transform versionify 
        #..transform browserify-optimize-js

    return b 

# Concatenate vendor javascript files into public/js/vendor.js
compile-js = (watchlist, output) ->
    gulp.src watchlist
        .pipe cat output
        .pipe through2.obj (file, enc, cb) ->
            contents = file.contents.to-string!
            optimized = optimize-js contents
            file.contents = new Buffer.from optimized
            cb null, file

        # Remove the sourceMappingUrl part 
        .pipe through2.obj (file, enc, cb) ->
            contents = file.contents.to-string!
            removed = contents.replace /\/\/#\s?sourceMappingURL=.*\b/g, (x) -> 
                if DEBUG
                    log "Source Mapping URL is removed: #x"
                return ''
            file.contents = new Buffer.from removed
            cb null, file

        # ES-5 Transpilation MUST BE the last step
        .pipe through2.obj (file, enc, cb) ->
            if optimize-for-production
                contents = file.contents.to-string!
                es5 = my-buble contents
                file.contents = new Buffer.from es5
            cb null, file

        # compaction must be after ES-5 transpilation
        .pipe if-else optimize-for-production, my-uglify
        .pipe gulp.dest "#{paths.client-public}/js"

compile-css = (watchlist, output) ->
    gulp.src watchlist
        .pipe cssimport {includePaths: ['node_modules', '../node_modules']}
        .pipe cat output

        # themes are searched in ../themes path, so do not save css in root
        # folder
        .pipe gulp.dest "#{paths.client-public}/css"

debug-cache = (cache) -> 
    o = JSON.parse JSON.stringify cache 
    simplify-object = (obj) -> 
        for k, v of obj
            if k is \source 
                obj[k] = "Some #{v.length} characters long string"
            if typeof! v is \Object 
                obj[k] = simplify-object v
        return obj 

    return JSON.stringify simplify-object(o), null, 2

# Gulp Tasks 
# ---------------------

# Browserify
# --------------
gulp.task \browserify, (done) !-> 
    b-count = app-entry-files.length
    for let file in app-entry-files
        filebase = file.split(/[\\/]/).pop! .replace /\.[a-z]+/, '.js'
        log "* Created bundler task for #{filebase}"
        b = get-bundler file
        do bundle = -> 
            t0 = Date.now!
            b
            .bundle!
            .on \error, (err) ->
                #console.log "browserify error is:", err 
                msg = err?annotated or err?message or err 
                on-error \browserify, msg
                b.__last_error = true 
                @emit \end

            .pipe source filebase
            .pipe buffer!

            # ES-5 Transpilation MUST BE the last step
            .pipe through2.obj (file, enc, cb) ->
                if optimize-for-production
                    contents = file.contents.to-string!
                    t0 = Date.now!
                    es5 = my-buble contents
                    file.contents = new Buffer.from es5
                    log "#{filebase} is transpiled to ES6 in #{round-ms (Date.now! - t0)}s"
                cb null, file

            # --- DO NOT CHANGE THE ORDER --- 
            # Although ES-5 Transpilation MUST BE the last step, 
            # if "my-uglify" is executed before ES-5 transpilation, 
            # it takes forever to transpile the uglified output.             
            .pipe if-else optimize-for-production, my-uglify
            .pipe rename (.extname = '.js')
            .pipe gulp.dest "#{paths.client-public}/js"
            .pipe tap (file) ->
                b-count-- if b-count > -1
                duration-str = "#{round-ms (Date.now! - t0)}s"
                if b-count is 0 
                    # first run completed 
                    log-info \browserify, "All Browserify jobs finished. (took #{duration-str})"
                    done!
                else if b-count is -1
                    # consequent runs 
                    log-info \browserify, "Browserified #{filebase} (took #{duration-str})", 
                        {noConsole: not b.__last_error}

                    # display "successfully compiled" message first time after an error
                    b.__last_error = false 

                if DEBUG 
                    log "Dumping Cache and Package cache."

                    # Cache data
                    cache = b._options.cache
                    fs.writeFile "debug-cache.json", debug-cache(cache), -> 
                        log "Cache is written to disk."

                    # Package data 
                    pkgcache = b._options.packageCache
                    fs.writeFile "debug-package-cache.json", debug-cache(pkgcache), -> 
                        log "Package Cache is written to disk."

        unless optimize-for-production
            b.on \update, (ids) !-> 
                bundle!

gulp.task \versionTrack, (done) ->
    unless argv.enable-version-polling
        unless optimize-for-production
            log-info "Version Track", 
                "TIP: \"make update-app-version\" manually."
        return done!
    curr = null 
    <~ :lo(op) ~>
        #console.log "checking project version...", curr
        version <~ get-version paths.client-root
        if (JSON.stringify(version) isnt JSON.stringify(curr)) 
            pfx = if curr is null 
                # first run 
                "App version"
            else 
                "Changed app version"
            curr := JSON.parse JSON.stringify version
            log "#{pfx}: ", curr
            touch.sync path.join __dirname, 'app-version.json'
        <~ sleep 1000ms
        lo(op)

gulp.task \html, (done) ->
    # Workaround with if/else:
    # Couldn't make it work like this: https://stackoverflow.com/a/60743545/1952991
    unless empty html-entry-files
        gulp.src html-entry-files, {+allowEmpty}
            #.pipe rename basename: app
            .pipe flatten!
            .pipe gulp.dest paths.client-public        
    done!

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

gulp.task \assets, ->
    sep = if /^win/.test process.platform => '\\' else '/'
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
gulp.task \pug (done) ->
    unless empty pug-entry-files
        gulp.src pug-entry-files, {+allowEmpty}
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
    done!


gulp.task \watchChanges, (done) ->
    unless optimize-for-production
        watch pug-entry-files, gulp.series \pug 
        watch html-entry-files, gulp.series \html
        watch for-css, gulp.series \vendor-css
        watch for-js, gulp.series \vendor-js
        watch for-css2, gulp.series \vendor2-css
        watch for-js2, gulp.series \vendor2-js
        watch for-assets, gulp.series \assets
        # browserify watches the required files by itself via watchify
    done!

# Start the tasks
gulp.task \default, gulp.series do
    \html
    \vendor-js
    \vendor-css
    \vendor2-js
    \vendor2-css
    \assets
    \pug
    \watchChanges
    \versionTrack
    \browserify
