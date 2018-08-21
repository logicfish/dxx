module dxx.app.injector;

private import aermicioi.aedi;

private import std.stdio;
private import std.experimental.logger;

private import dxx.app.workflow;

static string[string] readInjectorProperties(File* f) {
    string[string] res;
    return res;
}

static void registerInjectorProperties(string[string] properties) {
}

static auto resolveInjector(alias T,Arg...)(Arg arg) {
    return DefaultInjector._DEFAULT_CONTAINER.locate!T(arg);
}

static auto newInjector(alias T)(ConfigurableContainer c = DefaultInjector._DEFAULT_CONTAINER) {
    return new ContextInjector!T(c);
}

abstract class DefaultInjector {

        static __gshared ConfigurableContainer _DEFAULT_CONTAINER;

        @property
        ConfigurableContainer container;

        shared static this() {
            debug {
                sharedLog.info("Creating shared container.");
            }
            _DEFAULT_CONTAINER = prototype(); 
            scope(exit) _DEFAULT_CONTAINER.terminate();
        }
        this(ConfigurableContainer c = _DEFAULT_CONTAINER) {
            container = c;
        }
        void registerProperties(string[string] properties) {
        }
        auto resolve(alias T)() {
            return container.locate!T;
        }
        void register(T...)() {
            container.register!T;
        }
        auto configure() {
            return container.configure;
        }
        auto instantiate() {
            return container.instantiate;
        }
}


final class ContextInjector(alias C ) : DefaultInjector {
    this(ConfigurableContainer c = _DEFAULT_CONTAINER) {
        super(c);
        c.scan!C;
    }
}

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

