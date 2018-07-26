Ractive.components["ace-editorLOADING"] = Ractive.extend do
    template: RACTIVE_PREPARSE('loading.pug')

Ractive.partials["ace-editor"] = get-synchronizer "ace-editorLOADING"
