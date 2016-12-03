require! 'through2': through
require! <[ pug path cheerio ]>
require! 'ractive':Ractive
require! 'prelude-ls': {map}

/*
module.exports = (file) ->
    through (buf, enc, next) ->
        this.push(buf.toString('utf8').replace /\$CWD/gm, process.cwd!)
        next!
*/
module.exports = (file) ->
    through (buf, enc, next) ->
        content = buf.to-string \utf8
        dirname = path.dirname file
        preparse-jade = (m, params-str) ->
            [jade-file, template-id] = params-str.split ',' |> map (.replace /["'\s]+/g, '')

            jade-file-full-path = path.join dirname, jade-file
            html = try
                pug.render-file jade-file-full-path
            catch
                console.error "ERROR: ractive-parserify: #{e}"
                ''

            template-html = if template-id
                $ = cheerio.load html
                try
                    $ template-id .html!
                catch
                    console.error "can not get template id: #{template-id} from ", html
                    ''
            else
                html

            console.log "ractive-preparsify: compiling template: #{path.basename path.dirname file}/#{jade-file} #{template-id or \ALL_HTML }"

            parsed-template = Ractive.parse template-html
            JSON.stringify parsed-template

        this.push(content.replace /RACTIVE_PREPARSE\(([^\)]+)\)/g, preparse-jade)
        next!
