module dxx.app.parsers.workflow;

private import dxx.app.workflow;

// grammar

private import pegged.grammar;
private import dxx.util.injector;

mixin(grammar(import("workflow.peg")));

/*
static Workflow parseWorkflow(string wf) {
    auto g = WorkflowGrammar(wf);
    WorkflowElement elem_value(ParseTree p) {
        string id = p.matches.join('.');
        auto e = resolveInjector!WorkflowElement(id);
        foreach(w;p.children) {
            //switch(w.name) {
            //}
        }
        return e;
    }
    Workflow wf_value(ParseTree p) {
        WorkflowElement[] e;
        foreach(w;p.children) {
            switch(w.name) {
                case "WorkflowDoc.WorkflowHeader":
                break;
                case "WorkflowDoc.WorkflowElement":
                e ~= elem_value(w);
            }
        }
        return new DefaultWorkflow(e,arg);
    }
    Workflow[string] value(ParseTree p) {
        switch (p.name) {
            case "WorkflowDoc" :
            Workflow[string] wf;
            // options...
            foreach(w;p.children[0..$]) {
                switch(w.name) {
                    case "WorkflowDoc.WorkflowHeader" :
                    break;
                    case "WorkflowDoc.WorkflowDefinition" :
                    wf[w.matches[0]] = wf_value(wf);
                }
            }
            return wf;
            default:
        }
    }
    
    return wf(g);
}
*/

