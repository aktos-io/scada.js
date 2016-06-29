gulp = require \gulp
browserify = require \browserify
lsc = require 'gulp-livescript'
clean = require 'gulp-clean'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
glob = require 'glob'

gulp.task \default, -> 
    console.log "task lsc is running.."
    gulp.start <[ browserify html]>

gulp.task \lsc ->
    gulp.src ['./src/app/*.ls']
    .pipe lsc!
    .pipe gulp.dest './public/compiled-js'


gulp.task \browserify <[ clean-js lsc ]> -> 
    glob './public/compiled-js/*.js', (err, filepath) -> 
        for f in filepath
            filename = f.split '/' .slice -1
            browserify f
                .bundle!
                .pipe source "./public/app/#{filename}"
                .pipe buffer!
                .pipe gulp.dest './public/app'

gulp.task \clean-js, ->
    console.log "Cleaned build directory..."
    gulp.src './public/**/*.js'
    .pipe clean! 

gulp.task \html, -> 
    gulp.src './src/app/*.html'
        .pipe gulp.dest './public/app'
