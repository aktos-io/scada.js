var modes = ace.require('ace/ext/modelist')
Ractive.components['ace-editor'] = Ractive.extend({
    template: '<div class="editor" ></div>',
    onrender: function(){
        var e = ace.edit( this.find('*') ),
            ractive = this,
            getting, setting;

        e.getSession().setMode('ace/mode/javascript')

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
