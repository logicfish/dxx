module dxx.app.workflow;

private import std.algorithm;

private import dxx.app.job;

interface WorkflowElement {
    void process(WorkflowJob job);
}

abstract class WorkflowElementBase : WorkflowElement {
    override void process(WorkflowJob job) {
        processElement(job);
    }
    abstract void processElement(WorkflowJob job);
}

interface Workflow {
    @property
    WorkflowElement[] workflowElements();
    @property
    string[] args();
}

abstract class WorkflowBase : Workflow {
    WorkflowElement[] _workflowElements;
    string[] _args;
    
    @property
    WorkflowElement[] workflowElements() {
        return _workflowElements;
    }
    @property
    string[] args() {
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
    Workflow workflow() {
        return _workflow;
    }
    override void executeJob() {
        workflow.workflowElements.each!(e=>e.process(this));
    }
}

final class WorkflowRunner {
    Job createJob(Workflow wf) {
        auto job = new WorkflowJob(wf);
        return job;
    }
}

