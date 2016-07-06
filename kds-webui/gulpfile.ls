{union} = require \prelude-ls
require! 'gulp-livescript': lsc
require! <[ gulp glob path]>
require! 'vinyl-source-stream': source
require! 'vinyl-buffer': buffer
require! 'vinyl-transform': transform
require! 'gulp-plumber': plumber
require! 'gulp-watch': watch
require! 'gulp-jade': jade
require! 'node-notifier': notifier
require! 'gulp-concat': cat
require! 'browserify-livescript'
require! 'browserify': browserify
require! 'gulp-uglify': uglify

# TODO: combine = require('stream-combiner')

# Build Settings
notification-enabled = yes

# Project Folder Structure
vendor-folder = './vendor'
server-src = "./src/server"
client-src = './src/client'
build-folder = "./build"
client-public = "#{build-folder}/public"
client-tmp = "#{build-folder}/__tmp"
lib-src = "./src/lib"

on-error = (source, err) ->
    msg = "GULP ERROR: #{err?.to-string!}"
    notifier.notify {title: "GULP.#{source}", message: msg} if notification-enabled
    console.log msg


# Tasks
gulp.task \default, ->
    console.log "task lsc is running.."
    run = -> gulp.start <[ browserify html vendor vendor-css assets jade ]>
    run!
    watch "#{client-src}/**/*.*", (event) ->
        run!
    watch "#{vendor-folder}/**", (event) ->
        gulp.start <[ vendor vendor-css ]>

gulp.task \lsc-client, ->
    gulp.src "#{client-src}/**/*.ls", {base: client-src}
        .pipe lsc!
        .on \error, (err) ->
            on-error \lsc-lib, err
            @emit \end
        .pipe gulp.dest client-tmp

gulp.task \lsc-lib, ->
    gulp.src "#{lib-src}/**/*.ls", {base: lib-src}
        .pipe lsc!
        .on \error, (err) ->
            on-error \lsc-lib, err
            @emit \end
        .pipe gulp.dest client-tmp


gulp.task \browserify <[ lsc-client lsc-lib ]> ->
    glob "#{client-tmp}/**/*.js", (err, filepath) ->
        for f in filepath
            filename = f.split '/' .slice -1
            base-folder = "#{f}" - "#{client-tmp}/" - "/#{filename}"
            browserify f, {paths: ["#{client-tmp}"]}
                .bundle!
                .on \error, (err) ->
                    on-error \browserify, err
                    @emit \end
                .pipe source "#{filename}"
                .pipe buffer!
                .pipe gulp.dest "#{client-public}/#{base-folder}"



gulp.task \html, ->
    gulp.src "#{client-src}/*.html"
        .pipe gulp.dest client-public

gulp.task \vendor, ->
    order =
        \ractive.js
        \jquery-1.12.0.min.js

    glob "#{vendor-folder}/**/*.js", (err, files) ->
        ordered-list = union order, [path.basename .. for files]
        #console.log "ordered list is: ", ordered-list
        gulp.src ["#{vendor-folder}/#{..}" for ordered-list]
            .pipe cat "vendor.js"
            .pipe gulp.dest "#{client-public}/js"

gulp.task \vendor-css, ->
    glob "#{vendor-folder}/**/*.css", (err, files) ->
        gulp.src files
            .pipe cat "vendor.css"
            .pipe gulp.dest "#{client-public}/css"

gulp.task \assets, ->
    gulp.src "#{client-src}/assets/**/*", {base: "#{client-src}/assets"}
        .pipe gulp.dest client-public

gulp.task \jade, ->
    # TODO: exclude list!
    # exclude-list =
    #   template.jade
    #   mixins.jade
    gulp.src "#{client-src}/**/*.jade", {base: client-src}
        .pipe jade {pretty: yes}
        .on \error, (err) ->
            on-error \jade, err
            @emit \end
        .pipe gulp.dest client-public
