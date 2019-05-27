/**
{{app.docHeader}}
**/
module {{app.genModuleName}}.{{app.ID}}gen;

void {{app.ID}}_generate() {
    // run the default templates...
    Platform.loadWorkflow("{{app.workflowDir}}/autogen.wf");
    Platform.runWorkflow("{{app.ID}}_autogen");
}
