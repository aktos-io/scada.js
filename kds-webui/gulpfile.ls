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

vendor-folder = './vendor'
client-src = './src'
client-public = './public'

gulp.task \default, ->
    console.log "task lsc is running.."
    run = -> gulp.start <[ browserify html vendor vendor-css ]>
    run!
    gulp.watch './src/**/*.*', -> run!

gulp.task \lsc ->
    gulp.src ['./src/app/*.ls']
    .pipe lsc!
    .pipe gulp.dest './public/compiled-js'


gulp.task \browserify <[ lsc ]> ->
    glob './public/compiled-js/*.js', (err, filepath) ->
        for f in filepath
            filename = f.split '/' .slice -1
            browserify f
                .bundle!
                .on \error, (err) ->
                    console.log "Error while bundling: ", err

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
        console.log "css list is: ", files
        gulp.src files
            .pipe concat "vendor.css"
            .pipe gulp.dest "./public/app"
