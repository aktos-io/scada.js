var modes = ace.require('ace/ext/modelist')
Ractive.components['ace-editor'] = Ractive.extend({
    template: '<div class="editor"></div>',
    onrender: function(){
        var e = ace.edit( this.find('*') ),
            ractive = this,
            getting, setting;

        var mode = ractive.get('mode') || 'javascript';
        console.log('mode is: ' + mode) || 'monokai';
        var theme = ractive.get('theme');
        e.setTheme("ace/theme/" + theme);
        e.getSession().setMode('ace/mode/' + mode);
        e.$blockScrolling = Infinity;
        ace.require("ace/edit_session").EditSession.prototype.$useWorker=false;

        this.observe('code', function(v){
            if(getting) return;
            setting = true;
            e.setValue(v);
            e.clearSelection();
            setting = false;
        })

        e.on('change', function(){
            console.log('editor change')
            if(setting) return;
            getting = true;
            ractive.set('code', e.getValue());
            getting = false;
        })
    }
});
