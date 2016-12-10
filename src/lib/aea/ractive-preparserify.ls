require! 'through2': through
require! <[ pug path cheerio ]>
require! 'ractive':Ractive
require! 'prelude-ls': {map}

/*******************************************************************************

USAGE:

Replace `template: '#my-template'` with
    * `template: RACTIVE_PREPARSE('my-template.pug')` if file contains only template code
    * `template: RACTIVE_PREPARSE('my-template.pug', '#some-template-id')` if file contains multiple template codes

Example:

    In the main ractive instance:

        ractive = new Ractive do
            el: '#main-output'
            template: RACTIVE_PREPARSE('base.pug')


    In a component file:

        Ractive.components.checkbox = Ractive.extend do
            template: RACTIVE_PREPARSE('index.pug')
            isolated: yes
            oninit: ->

********************************************************************************/

module.exports = (file) ->
    through (buf, enc, next) ->
        __ = this
        content = buf.to-string \utf8
        dirname = path.dirname file
        preparse-jade = (m, params-str) ->
            [jade-file, template-id] = params-str.split ',' |> map (.replace /["'\s]+/g, '')

            jade-file-full-path = path.join dirname, jade-file
            try
                html = pug.render-file jade-file-full-path
            catch _ex
                e = {}
                #console.error "ERROR: ractive-parserify: #{e}"
                e.name = 'Ractive Preparse Error'
                e.message = _ex.message
                e.fileName = jade-file-full-path
                __.emit 'error', e
                return



            template-html = if template-id
                $ = cheerio.load html
                try
                    $ template-id .html!
                catch
                    console.error "ERROR: ractive-preparserify: can not get template id: #{template-id} from ", html
                    ''
            else
                html

            # Debug
            #console.log "DEBUG: ractive-preparsify: compiling template: #{path.basename path.dirname file}/#{jade-file} #{template-id or \ALL_HTML }"
            # End of debug

            parsed-template = Ractive.parse template-html
            JSON.stringify parsed-template

        this.push(content.replace /RACTIVE_PREPARSE\(([^\)]+)\)/g, preparse-jade)
        next!
