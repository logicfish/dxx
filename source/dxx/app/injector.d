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

static T inject(T)(T t) {
//    DefaultInjector._DEFAULT_CONTAINER.autowire(t);
    return t;
}

static auto resolveInjector(alias T)() {
//    return DefaultInjector._DEFAULT_CONTAINER.resolve!T;
    return null;
}

abstract class DefaultInjector {

    static void inject(T)(T t) {
        //DefaultInjector._DEFAULT_CONTAINER.autowire(t);
        //Annotations.process(t);
    }

    //static auto newInjector(T...)(shared(DependencyContainer) c = DefaultInjector._DEFAULT_CONTAINER) {
    //    return new Injector!T(c);
    //}
    static auto newInjector(T...)() {
        return new ContextInjector!T();
    }

    static auto resolveInjector(alias T)() {
//        return DefaultInjector._DEFAULT_CONTAINER.resolve!T;
        return null;
    }

    static void registerInjectorProperties(string[string] properties) {
//       DefaultInjector._DEFAULT_CONTAINER.registerProperdProperties(properties);
    }

//        static __gshared shared(DependencyContainer) _DEFAULT_CONTAINER;
//
//        @property
//        shared(DependencyContainer) container;

        shared static this() {
           debug {
            sharedLog.info("Creating shared container.");
          }
//          _DEFAULT_CONTAINER = new shared(DependencyContainer)();
//          _DEFAULT_CONTAINER.setPersistentRegistrationOptions(RegistrationOption.doNotAddConcreteTypeRegistration);
//          _DEFAULT_CONTAINER.setPersistentResolveOptions(ResolveOption.registerBeforeResolving);
        }
//        this(shared(DependencyContainer) c = _DEFAULT_CONTAINER) {
//          container = c;
//          wire(this);
//        }
        void wire(T)(T t) {
//            container.autowire(t);
    //        Annotations.process(t);
        }
        void registerProperties(string[string] properties) {
//           container.registerProperdProperties(properties);
        }
        auto resolve(alias T)() {
//            return container.resolve!T;
        }
        void register(T...)() {
//            container.register!T;
        }
}


final class ContextInjector(C ...) : DefaultInjector {
    shared static this() {
        static foreach(cls;C) {
            debug { sharedLog.info("Register context: ",typeid(cls)); }
            //_DEFAULT_CONTAINER.registerContext!cls;
        }
    }
    //this(shared(DependencyContainer) c = _DEFAULT_CONTAINER) {
    //  super(c);
    //}
}

abstract class Module {
    static __gshared Module APP_MODULE;

    DefaultInjector injector;

    this() {
        if(APP_MODULE is null) {
            APP_MODULE = this;
        }
    }
    
}

class AppModule(C ...) {
    this() {
        injector = newInjector!C;
    }
}

