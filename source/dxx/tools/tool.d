module dxx.tools.tool;

private import dxx.tools;

struct ToolOptions {
    string organisation;
    string projectName;
    string projectVersion;
    string symbolicName;
    string author;
    string license;
    string lang;
    string desc;
}

interface Tool : WorkflowElement {
    enum OK = 0;
    int run(string[] args);
}

abstract class ToolBase : WorkflowElementBase, Tool {
    int status = OK;
    override void processElement(WorkflowJob job) {
        status = run(job.workflow.args);
    }
}


