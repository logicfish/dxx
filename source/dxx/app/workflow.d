/**
Copyright 2018 Mark Fisher

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
module dxx.app.workflow;

private import std.algorithm;

private import dxx.app.job;

interface WorkflowElement {
    void processElement(WorkflowJob job);
}

//abstract class WorkflowElementBase : WorkflowElement {
//    override void process(WorkflowJob job) {
//        processElement(job);
//    }
//    abstract void processElement(WorkflowJob job);
//}

interface Workflow {
    @property
    ref inout (WorkflowElement[]) workflowElements() inout;
    
    @property
    ref inout (string[]) args() inout;
}

abstract class WorkflowBase : Workflow {
    WorkflowElement[] _workflowElements;
    string[] _args;
    
    @property
    ref inout (WorkflowElement[]) workflowElements() inout {
        return _workflowElements;
    }
    @property
    ref inout (string[]) args() inout {
        return _args;
    }
    this(WorkflowElement[] elements,string[] args) {
        _workflowElements = elements;
        _args = args;
    }
}

final class DefaultWorkflow : WorkflowBase {
    this(WorkflowElement[] elements,string[] args) {
        super(elements,args);
    }
}

final class WorkflowJob : JobBase {
    Workflow _workflow;
    this(Workflow wf) {
        this._workflow = wf;
    }
    @property
    inout(Workflow) workflow() inout {
        return _workflow;
    }
    override void executeJob() {
        workflow.workflowElements.each!(e=>e.processElement(this));
    }
}

final class WorkflowRunner {
    Job createJob(Workflow wf) {
        auto job = new WorkflowJob(wf);
        return job;
    }
}

unittest {
    import std.stdio;
    
    class TestWorkflowElement : WorkflowElement {
        bool _done = false;
        override void processElement(WorkflowJob job) {
            writeln("TestWorkflowElement.processElement");
            _done = true;
        }
    }
    string[] arg = [ "arg0","arg1","arg2" ];
    
    auto elem = new TestWorkflowElement;
    WorkflowElement[] e = [ elem ];
    auto wf = new DefaultWorkflow(e,arg);
    auto r = new WorkflowRunner;
    auto j = r.createJob(wf);
    j.execute();
    assert(j.terminated);
    assert(j.status == Job.Status.TERMINATED);
    assert(elem._done);
    
}

unittest {
    import std.stdio;
    class TestWorkflowElementException : WorkflowElement {
        override void processElement(WorkflowJob job) {
            writeln("TestWorkflowElementException.processElement");
            throw new Exception("workflow unittest");
        }
    }
    string[] arg = [ "arg0","arg1","arg2" ];
    
    auto elem = new TestWorkflowElementException;
    WorkflowElement[] e = [ elem ];
    auto wf = new DefaultWorkflow(e,arg);
    auto r = new WorkflowRunner;
    auto j = r.createJob(wf);
    j.execute();
    assert(j.terminated);
    assert(j.status == Job.Status.THROWN_EXCEPTION);
    assert(j.thrownException !is null);
}

