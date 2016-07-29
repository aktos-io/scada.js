require! <[ gulp glob path fs globby]>
require! 'prelude-ls': {union, join}
require! 'gulp-livescript': lsc
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'gulp-watch': watch
require! 'gulp-jade': jade
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'browserify': browserify
require! 'gulp-uglify': uglify
require! './src/lib/aea': {sleep}
require! 'gulp-flatten': flatten
require! 'gulp-tap': tap
require! 'gulp-cached': cache
require! 'gulp-clean': clean

argv = require 'yargs' .argv

# Build Settings
notification-enabled = yes

# Project Folder Structure
paths = {}
paths.vendor-folder = "#{__dirname}/vendor"
paths.server-src = "#{__dirname}/src/server"
paths.build-folder = "#{__dirname}/build"

paths.client-public = "#{paths.build-folder}/public"
paths.client-src = "#{__dirname}/src/client"
paths.client-tmp = "#{paths.build-folder}/__client-tmp"
paths.client-apps = "#{paths.client-public}"

paths.lib-src = "#{__dirname}/src/lib"
paths.lib-tmp = "#{paths.build-folder}/__lib-tmp"

paths.components-src = "#{paths.client-src}/components"
paths.components-tmp = "#{paths.client-tmp}/components"


console.log "Paths: "
for p, k of paths
    console.log "PATH for #{p} is: #{k}"
console.log "---------------------------"

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

# Organize Tasks
gulp.task \default, ->
    console.log "task lsc is running.."
    console.log "cleaning build directory"

    gulp.src \build
        .pipe clean {+force, -read}
    <- sleep 1000ms
    console.log "build directory cleaned..."

    do function run-all
        gulp.start <[ js browserify html vendor vendor-css assets jade ]>

    if argv.compile is true
        console.log "Gulp compiled only once..."
        return

    for-browserify =
        # include
        "#{paths.client-src}/components/**/*.ls"
        "#{paths.client-src}/components/**/*.js"
        "!#{paths.client-src}/components/components.ls"

        "#{paths.lib-src}/**/*.ls"
        "#{paths.lib-src}/**/*.js"
    watch for-browserify, (event) ->
        # changes in components should trigger browserify via removing its cache entry

        delete cache.caches['browserify']
        gulp.start <[ browserify ]>
    for-browserify-apps =
            "#{paths.client-src}/apps/**/*.ls"

    watch for-browserify-apps, (event) ->
        # changes in components should trigger browserify via removing its cache entry
        delete cache.caches['browserify']
        gulp.start <[ browserify ]>


    for-jade =
        "#{paths.client-src}/components/**/*.jade"
        "!#{paths.client-src}/components/components.jade"

        "#{paths.client-src}/apps/**/*.jade"
        "#{paths.client-src}/templates/**/*.jade"

    watch for-jade, ->
        gulp.start \jade

    watch "#{paths.vendor-folder}/**", (event) ->
        gulp.start <[ vendor vendor-css ]>

    watch "./node_modules/**", (event) ->
        run-all!

# Copy js and html files as is
gulp.task \js, ->
    gulp.src "#{paths.client-src}/**/*.js", {base: paths.client-src}
        .pipe gulp.dest paths.client-tmp

gulp.task \html, ->
    base = "#{paths.client-src}/apps"
    gulp.src "#{base}/**/*.html", {base: base}
        .pipe gulp.dest "#{paths.client-public}"


# Compile client LiveScript files into temp folder
gulp.task \lsc-components <[ generate-components-module ]> ->
    console.log "RUNNING LSC_COMPONENTS"
    gulp.src ["#{paths.components-src}/*/*.ls", "#{paths.components-src}/components.ls"], {base: paths.client-src}
        .pipe lsc!
        .on \error, (err) ->
            on-error \lsc-lib, err
            @emit \end
        .pipe gulp.dest paths.client-tmp


gulp.task \lsc-apps <[ lsc-components ]> ->
    console.log "RUNNING LSC_apps"
    base = "#{paths.client-src}/apps"
    gulp.src "#{base}/**/*.ls", {base: base}
        .pipe lsc!
        .on \error, (err) ->
            on-error \lsc-lib, err
            @emit \end
        .pipe gulp.dest "#{paths.client-tmp}/apps"


gulp.task \generate-components-module ->
    console.log "RUNNING GENERATE_COMPONENTS_MODULE"
    components = glob.sync "#{paths.components-src}/**/*.ls"
    components = [.. for components when is-module-index paths.components-src, ..]
    index = "#{paths.components-src}/components.ls"
    components = [.. for components when .. isnt index]
    components = [path.basename path.dirname .. for components]

    fs.write-file-sync index, '' # delete the file
    fs.append-file-sync index, '# Do not edit this file manually! \n'
    fs.append-file-sync index, join "" ["require! './#{..}'\n" for components]
    fs.append-file-sync index, "module.exports = { #{join ', ', components} }\n"



# Compile library modules into library temp folder
gulp.task \lsc-lib, ->
    console.log "RUNNING LSC_LIB"
    gulp.src "#{paths.lib-src}/**/*.ls", {base: paths.lib-src}
        .pipe lsc!
        .on \error, (err) ->
            on-error \lsc-lib, err
            @emit \end
        .pipe gulp.dest paths.lib-tmp
    console.log "ENDED LSC_LIB"

# Browserify apps/* into public folder

gulp.task \lsc <[ lsc-lib lsc-apps ]>, ->
    console.log "RUNNING LSC (which means ended)"
    console.log "lsc ended..."

gulp.task \browserify <[ lsc js]>, (done) ->
    base = "#{paths.client-tmp}/apps"
    files = glob.sync "#{base}/**/*.js"

    files = [.. for files when is-module-index base, ..]

    do function bundle-all
        console.log "BUNDLE_ALL STARTED..."
        i = 0
        <- :lo(op) ->
            file = files[i]
            filename = path.basename file
            console.log "Started Browserifying file: ", path.basename file
            browserify file, {paths: [paths.components-tmp, paths.lib-tmp]}
                .bundle!
                .on \error, (err) ->
                    on-error \browserify, err
                    @emit \end
                .pipe source filename
                #.pipe buffer!
                #.pipe uglify!
                .pipe gulp.dest paths.client-apps
                .on 'end', ->
                    if ++i >= files.length
                        console.log "returning..."
                        return op!
                    else
                        console.log "browserify continues"
                        lo(op)

        console.log "BUNDLE_ALL FINISHED..."
        for f in files
            console.log " * #{path.basename f}"

        msg = "Finished!"
        log-info "Browserify", msg

        #done!

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
        .pipe gulp.dest paths.client-apps

# Compile Jade files in paths.client-src to the paths.client-tmp folder
gulp.task \jade <[ jade-components ]> ->
    base = "#{paths.client-src}/apps"
    files = glob.sync "#{base}/**/*.jade"
    files = [.. for files when is-module-index base, ..]
    gulp.src files
        .pipe tap (file) ->
            console.log "JADE: compiling file: ", path.basename file.path
        .pipe jade {pretty: yes}
        .on \error, (err) ->
            on-error \jade, err
            @emit \end
        .pipe flatten!
        .pipe gulp.dest paths.client-apps


gulp.task \jade-components ->
    # create a file which includes all jade file includes in it
    console.log "STARTED JADE_COMPONENTS"

    base = paths.components-src
    main = "#{base}/components.jade"

    components = globby.sync ["#{base}/**/*.jade", "!#{base}/components.jade"]
    components = [path.relative base, .. for components]

    for i in components
        console.log "jade-component: ", i


    # delete the main file
    fs.write-file-sync main, '// Do not edit this file manually! \n'

    for comp in components
        fs.append-file-sync main, "include #{comp}\n"
