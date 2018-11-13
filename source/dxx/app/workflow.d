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
    void setup(WorkflowJob job);
    void process(WorkflowJob job);
    void terminate(WorkflowJob job);
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
    
    @property
    ref inout (string[string]) param() inout;
}

abstract class WorkflowBase : Workflow {
    WorkflowElement[] _workflowElements;
    string[] _args;
    string[string] _param;
    
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
    @property
    ref inout (string[string]) param() inout {
        return _param;
    }
}

final class DefaultWorkflow : WorkflowBase {
    this(WorkflowElement[] elements,string[] args) {
        super(elements,args);
    }
}

final class WorkflowJob : JobBase {
    Workflow _workflow;
    WorkflowRunner _runner;
    string[string] _param;
    
    this(Workflow wf,WorkflowRunner r) {
        this._workflow = wf;
        this._runner = r;
        this._param = wf.param.dup;
    }
    @property
    inout(Workflow) workflow() inout {
        return _workflow;
    }
    @property
    inout(WorkflowRunner) workflowRunner() inout {
        return _runner;
    }
    override void executeJob() {
        workflow.workflowElements.each!(e=>e.setup(this));
        try {
            workflow.workflowElements.each!(e=>e.process(this));
        } finally {
            workflow.workflowElements.each!(e=>e.terminate(this));
        }
    }
    @property
    ref inout (string[string]) param() inout {
        return _param;
    }
}

final class WorkflowRunner {
    Job createJob(Workflow wf) {
        auto job = new WorkflowJob(wf,this);
        return job;
    }
}

class WorkflowElementDelegate(alias D) : WorkflowElement {
    override void setup(WorkflowJob job) {}
    override void process(WorkflowJob job) {
        D(job);
    }
    override void terminate(WorkflowJob job) {}
}

unittest {
    import std.stdio;
    
    class TestWorkflowElement : WorkflowElement {
        bool _done = false;
        override void setup(WorkflowJob job) {
            writeln("TestWorkflowElement.setup");
        }
        override void process(WorkflowJob job) {
            writeln("TestWorkflowElement.process");
            _done = true;
        }
        override void terminate(WorkflowJob job) {
            writeln("TestWorkflowElement.terminate");
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
        bool terminated = false;
        override void setup(WorkflowJob job) {
            writeln("TestWorkflowElement.setup");
        }
        override void process(WorkflowJob job) {
            writeln("TestWorkflowElementException.process");
            throw new Exception("workflow unittest");
        }
        override void terminate(WorkflowJob job) {
            writeln("TestWorkflowElement.terminate");
            terminated = true;
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
    assert(elem.terminated);
}


