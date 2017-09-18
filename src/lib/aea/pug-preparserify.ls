require! 'through2': through
require! <[ pug path cheerio fs ]>
require! 'prelude-ls': {map, keys}
require! '../../../templates/filters': {pug-filters}

export preparserify-dep-list = {}

/*

Example pug file:

        style.
            #hello {
                position: absolute;
                right: 10mm;
                top: 10mm;
                width: 80mm;
                height: 20mm;
                background-color: red;
            }

        h3 Sipariş kalem no barcode #{barcode}

        svg#hello
        script JsBarcode('#hello', '#{barcode}');

        .ui.form
            .fields
                .field
                    label Kısa Tarif
                    | #{entry.name}

*/

export pug-preparserify = (file) ->
    through (buf, enc, next) ->
        content = buf.to-string \utf8
        dirname = path.dirname file
        preparse-jade = (m, template-file) ~>
            template-file = template-file.replace /\'/g, ''
            #console.log "Pug preparserify template file: ", template-file
            template-full-path = path.join dirname, template-file
            try
                template-contents = fs.read-file-sync template-full-path .to-string!
            catch
                console.log "Preparserify error: ", e
                @emit 'error', e.message
                return

            template-contents = template-contents.replace /#{/g, '\\#{'

            try
                # include templates/mixins.pug file
                mixin-relative = path.relative dirname, process.cwd!
                mixin-include = "include #{mixin-relative}/templates/mixins.pug\n"
                template-contents = mixin-include + template-contents

                #console.log "template contents:"
                #console.log "------------------"
                #console.log template-contents

                try
                    # FIXME: We should get dependencies and rendered content in one function call
                    deps = (pug.compileClientWithDependenciesTracked template-contents, {filename: file, filters: pug-filters} .dependencies) or []
                    fn = pug.compile template-contents, {filename: file, filters: pug-filters}
                    # End of FIXME
                catch
                    console.log "Something went wrong here: ", e

                all-deps = deps ++ template-full-path
                for dep in all-deps
                    #console.log "dep is: ", dep, "for the file: ", file
                    if preparserify-dep-list[dep]
                        preparserify-dep-list[dep].push file
                    else
                        preparserify-dep-list[dep] = [file]

                #console.log "DEPS : ", JSON.stringify preparserify-dep-list, null, 2
                template-html = fn!
            catch
                @emit 'error', e
                return

            # Debug
            #console.log "DEBUG: pug-preparsify: compiling template: #{path.basename path.dirname file}/#{template-file}"
            console.log "template-html: "
            console.log "---------------"
            # End of debug

            template-html = template-html.replace /#/g, '\\#'

            h = "'''" + template-html + "'''"

            console.log h
            return h

        this.push(content.replace /PUG_PREPARSE\(([^\)]+)\)/g, preparse-jade)
        next!
