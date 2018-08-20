module dxx.app.injector;

private import aermicioi.aedi;

private import std.stdio;
private import std.experimental.logger;

static string[string] readInjectorProperties(File* f) {
    string[string] res;
    return res;
}

static void registerInjectorProperties(string[string] properties) {
}

static auto resolveInjector(alias T)() {
    return DefaultInjector._DEFAULT_CONTAINER.locate!T;
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
            _DEFAULT_CONTAINER = singleton(); 
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
}


final class ContextInjector(alias C ) : DefaultInjector {
    this(ConfigurableContainer c = _DEFAULT_CONTAINER) {
        super(c);
        c.scan!C;
        c.instantiate();
    }
}

abstract class Module {
    static __gshared Module APP_MODULE;

    DefaultInjector injector;

    this() {
        if(APP_MODULE is null) {
            APP_MODULE = this;
        }
    }
    //abstract void registerAppDependencies(DefaultInjector injector);
    @component
    public Logger getLogger() {
        return sharedLog;
    }
}

class AppModule(alias C ) : Module {
    this() {
        injector = newInjector!C;
    }
}

