module dxx.app.rtmod;

private import aermicioi.aedi;

private import std.experimental.logger;

private import dxx.util.injector;
private import dxx.app.workflow;

@component
abstract class RuntimeModule {
    static __gshared RuntimeModule MODULE;
    //static __gshared Module APP_MODULE;
    static __gshared WorkflowRunner workflowRunner;

    //static __gshared DefaultInjector injector;
    //DefaultInjector injector;

    //public this() {
    //    if(MODULE is null) {
    //        MODULE = this;
    //    }
    //}
    abstract void registerAppDependencies(DefaultInjector injector);

    @component
    public RuntimeModule getRuntimeModule() {
        return MODULE;
    }

    @component
    public Logger getLogger() {
        return sharedLog;
    }

    @component
    public WorkflowRunner getWorkflowRunner() {
        if(workflowRunner is null) {
            workflowRunner = new WorkflowRunner;
        }
        return workflowRunner;
    }

    public this(this T)() {
        if(MODULE is null) {
            MODULE = this;
        }
        auto injector = newInjector!T;
        registerAppDependencies(injector);
        injector.instantiate();
    }
}
