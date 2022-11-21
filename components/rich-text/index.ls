require! 'quill': Quill

Ractive.components['rich-text'] = Ractive.extend do
    template: '''
        <div id="quilleditor_{{_guid}}" class="{{class}}"></div>
        '''
    onrender: -> 
        options = {
          modules: {
            toolbar: [
                [{ header: [1, 2, 3, 4, 5, 6,  false] }],
                ['bold', 'italic', 'underline','strike'],
                ['image', 'code-block'],
                ['link'],
                [{ 'script': 'sub'}, { 'script': 'super' }],
                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                [{ 'indent': '-1'}, { 'indent': '+1' }],          # outdent/indent
                [{ 'direction': 'rtl' }],                         # text direction
                [{ 'size': ['small', false, 'large', 'huge'] }],  # custom dropdown
                [{ 'color': [] }, { 'background': [] }],          # dropdown with defaults from theme
                [{ 'font': [] }],
                [{ align: '' }, { align: 'center' }, { align: 'right' }, { align: 'justify' }]
                ['clean']                                         # remove formatting button
            ]
          },
          placeholder: @get('placeholder'),
          theme: 'snow'
        };
        
        editor = new Quill('#quilleditor_' + @_guid, options)

        observer = @observe 'value', (_new) -> 
            editor.clipboard.dangerouslyPasteHTML 0, _new

        editor.on 'text-change', (delta, oldDelta, source) ~>>
            if source is \user
                observer.silence!
                await @set 'value', editor.root.innerHTML
                observer.resume!

    data: -> 
        value: ""
        placeholder: ""