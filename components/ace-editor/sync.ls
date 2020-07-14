Ractive.components["ace-editorLOADING"] = Ractive.extend do
    template: require('./loading.pug')

Ractive.partials["ace-editor"] = get-synchronizer "ace-editorLOADING"
