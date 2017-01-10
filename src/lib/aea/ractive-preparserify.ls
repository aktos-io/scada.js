require! 'through2': through
require! <[ pug path cheerio fs ]>
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

export preparserify-dep-list = {}

export ractive-preparserify = (file) ->
    through (buf, enc, next) ->
        __ = this
        content = buf.to-string \utf8
        dirname = path.dirname file
        preparse-jade = (m, params-str) ->
            [template-file, template-id] = params-str.split ',' |> map (.replace /["'\s]+/g, '')

            ext = path.extname template-file
            template-full-path = path.join dirname, template-file
            try
                template-contents = fs.read-file-sync template-full-path .to-string!
            catch
                console.log "Preparserify error: ", e
                __.emit 'error', e.message
                return


            if ext is \.html
                template-html = template-contents
            else if ext is \.pug
                try
                    # include templates/mixins.pug file
                    mixin-relative = path.relative dirname, process.cwd!
                    mixin-include = "include #{mixin-relative}/src/client/templates/mixins.pug\n"
                    template-contents = mixin-include + template-contents

                    # FIXME: We should get dependencies and rendered content in one function call
                    deps = pug.compileClientWithDependenciesTracked template-contents, {filename: file} .dependencies
                    fn = pug.compile template-contents, {filename: file}
                    # End of FIXME

                    all-deps = deps ++ template-full-path
                    for dep in all-deps
                        #console.log "dep is: ", dep, "for the file: ", file
                        if preparserify-dep-list[dep]
                            preparserify-dep-list[dep].push file
                        else
                            preparserify-dep-list[dep] = [file]

                    #console.log "DEPS : ", JSON.stringify preparserify-dep-list, null, 2
                    template-html = fn!
                catch _ex
                    e = {}
                    #console.error "ERROR: ractive-parserify: #{e}"
                    e.name = 'Ractive Preparse Error'
                    e.message = _ex.message
                    e.fileName = template-full-path
                    console.log "cwd: ", process.cwd!
                    console.log "err file: ", template-full-path
                    __.emit 'error', _ex.message
                    return



            template-part = if template-id
                $ = cheerio.load template-html
                try
                    $ template-id .html!
                catch
                    console.error "ERROR: ractive-preparserify: can not get template id: #{template-id} from ", html
                    ''
            else
                template-html

            # Debug
            #console.log "DEBUG: ractive-preparsify: compiling template: #{path.basename path.dirname file}/#{jade-file} #{template-id or \ALL_HTML }"
            # End of debug

            try
                parsed-template = Ractive.parse template-part
            catch
                console.log "Preparserify Error: ", e
                __.emit 'error', e.message
                return

            JSON.stringify parsed-template

        this.push(content.replace /RACTIVE_PREPARSE\(([^\)]+)\)/g, preparse-jade)
        next!
