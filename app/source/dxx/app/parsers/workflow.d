/**
Copyright: 2019 Mark Fisher

License:
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/
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
