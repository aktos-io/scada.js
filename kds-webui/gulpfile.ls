# TODO: http://stackoverflow.com/questions/23971388/prevent-errors-from-breaking-crashing-gulp-watch

gulp = require \gulp
browserify = require \browserify
lsc = require \gulp-livescript
clean = require \gulp-clean
source = require \vinyl-source-stream
buffer = require \vinyl-buffer
glob = require \glob
concat = require \gulp-concat
{union} = require \prelude-ls
path = require \path
notifier = require \node-notifier
jade = require \gulp-jade
watch = require \gulp-watch
plumber = require \gulp-plumber

# TODO: combine = require('stream-combiner')

# Build Settings
notification-enabled = yes

# Project Folder Structure
vendor-folder = './vendor'
client-src = './src'
client-public = './public'

on-error = (err) ->
    msg = "GULP ERROR: #{err.to-string!}"
    notifier.notify {title: \GULP, message: msg} if notification-enabled
    console.log msg
    @emit \end


# Tasks
gulp.task \default, ->
    console.log "task lsc is running.."
    run = -> gulp.start <[ browserify html vendor vendor-css assets jade ]>
    run!
    watch './src/**/*.*', (event) ->
        run!
    watch "#{vendor-folder}/**", (event) ->
        gulp.start <[ vendor vendor-css ]>

gulp.task \lsc ->
    gulp.src ['./src/client/app/**/*.ls']
    .pipe lsc!
    .on \error, on-error
    .pipe gulp.dest './public/compiled-js'


gulp.task \browserify <[ lsc ]> ->
    glob './public/compiled-js/*.js', (err, filepath) ->
        for f in filepath
            filename = f.split '/' .slice -1
            browserify f
                .bundle!
                .on \error, on-error
                .pipe source "#{filename}"
                .pipe buffer!
                .pipe gulp.dest './public/app'

gulp.task \clean-js, ->
    console.log "Cleaned build directory..."
    gulp.src './public/**/*.js'
        .pipe clean!

gulp.task \html, ->
    gulp.src './src/app/*.html'
        .pipe gulp.dest './public/app'

gulp.task \vendor, ->
    order =
        \ractive.js
        \jquery-1.12.0.min.js

    glob './vendor/**/*.js', (err, files) ->
        ordered-list = union order, [path.basename .. for files]
        #console.log "ordered list is: ", ordered-list
        gulp.src ["./vendor/#{..}" for ordered-list]
            .pipe concat "vendor.js"
            .pipe gulp.dest "./public/app"

gulp.task \vendor-css, ->
    glob './vendor/**/*.css', (err, files) ->
        gulp.src files
            .pipe concat "vendor.css"
            .pipe gulp.dest "./public/app"

gulp.task \assets, ->
    gulp.src "./src/client/assets/**/*", {base: './src/client/assets'}
        .pipe gulp.dest client-public

gulp.task \jade, ->
    gulp.src "./src/client/**/*.jade", {base: './src/client'}
        .pipe jade {pretty: yes}
        .on \error, on-error
        .pipe gulp.dest client-public
