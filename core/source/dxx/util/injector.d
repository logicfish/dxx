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
module dxx.util.injector;

private import std.algorithm : each;
private import std.variant;
private import std.experimental.logger;
private import std.stdio;
private import std.process : environment;
private import std.typecons;

private import aermicioi.aedi;
private import aermicioi.aedi_property_reader;

private import dxx.sys.constants;
private import dxx.util.ini;
//private import dxx.util.storage;
private import dxx.util.config;

//static Variant[string] readInjectorProperties(File* f) {
//    Variant[string] res;
//    return res;
//}
//
//static void registerInjectorProperties(Variant[string] properties) {
    //InjectionContainer._DEFAULT_CONTAINER.each!(c=>{
    //    with(c.configure) {
    //        properties.each!((k,v)=>{
    //            if(v.type == typeid(string)) {
    //            }
    //        });
    //    }
    //});
    //properties.keys.each!((k)=>{
//	    if(v.type == typeid(string)) {
	//    	InjectionContainer.register!string(k);
//        }
//    });
//}

static auto resolveInjector(alias T,Arg...)(Arg arg,InjectionContainer i=InjectionContainer.getInstance) {
    return i.resolve!T(arg);
}

static T getInjectorProperty(T)(string k,InjectionContainer i=InjectionContainer.getInstance) {
    return i.resolve!T(k);
}

static void setInjectorProperty(T)(string k,T t,InjectionContainer i=InjectionContainer.getInstance) {
    i.register!T(t,k);
}

static auto newInjector(alias T,V...)(AggregateContainer c = null) {
    if(InjectionContainer.instantiated) {
        return InjectionContainer.getInstance;
    } else {
        return new ContextInjector!(T,V)(c);
    }
}

static void terminateInjector() {
    synchronized(InjectionContainer.classinfo) {
        if(InjectionContainer.INSTANCE) {
            InjectionContainer.INSTANCE.terminate;
        }
    }
}

abstract class InjectionContainer {

    private static __gshared InjectionContainer INSTANCE;
    static bool instantiated = false;

    static auto ref getInstance() {
        assert(INSTANCE !is null);
        return INSTANCE;
    }

    @property
    AggregateContainer _container;
        
    void services(T)(T parent) {
        auto s = singleton;
        auto p = prototype;

        configureSingleton(s);
        scanPrototype(p);

        parent.set(s,"singleton");
        parent.set(p,"prototype");    
        
    }        
    abstract void scanPrototype(PrototypeContainer);
    abstract void configureSingleton(SingletonContainer);
    //abstract void configureGlobals(AggregateContainer _container);    
    
    this(AggregateContainer _c) {
        synchronized(InjectionContainer.classinfo) {
            if(!instantiated) {
                if(INSTANCE is null) {
                    INSTANCE = this;
                }
                instantiated = true;
            }
        }
        services(_c);
        _container = _c;
    }

    auto resolve(T,Arg ...)(Arg arg) {
        return _container.locate!T(arg);
    }

    void register(T...)(const(string) arg) {
        with(_container.configure("prototype")) {
            register!T(arg);
        }
    }
    void register(T...)() {
        with(_container.configure("prototype")) {
            register!T();
        }
    }
    void register(T)(ref T t,const(string) arg) {
        with(_container.configure("singleton")) {
            register!T(t,arg);
        }
    }
    void setParam(T)(string k,T v) {
        with(container.configure("parameters")) {
            register!T(v,k);
        }
    }    
    T getParam(T)(string k) {
        return _container.locate!T(k);
    }   
    void terminate() {
        debug {
            sharedLog.info("terminating");
        }
        _container.terminate();
    }
    auto instantiate() {
        debug {
            sharedLog.info("instantiating");
        }
        return _container.instantiate;
    }
    abstract void load(T : DocumentContainer!X, X...)(T container);
}


final class ContextInjector(C...) : InjectionContainer {
    this(AggregateContainer c = null) {
        if(c is null) c = aggregate(config, "parameters");
        super(c);
    }
    override void scanPrototype(PrototypeContainer p) {
        debug {
            sharedLog.info("scanPrototype");
        }
        static foreach(c;C) {
            //debug {
            //    import std.conv;
            //    sharedLog.info("Scanning prototype: " ~ typeid(c).to!string);
            //}
            static if(isTuple!c) {
            } else {
                //pragma(msg,"scanning prototype: ");
                //pragma(msg,c);
                p.scan!c;
            }
        }
    }
    override void configureSingleton(SingletonContainer) {
    }
    
    auto config() {
        debug {
            sharedLog.info("config");
        }
        auto cont = container(
          argument,
          env,
          json("./dxx.json"),
          json(RTConstants.constants.appDir ~ "/dxx.json")
          //json("/etc/aedi-example/config.json"),
          //configFiles
           );
        foreach (c; cont) {
            load(c);
        }
        return cont;
    }
    void load(T : DocumentContainer!X, X...)(T container) {
        with (container.configure) {
            static foreach(c;C) {
                static if(isTuple!c) {
                    debug {
                        pragma(msg,"scanning parameters: ");
                        pragma(msg,c);
                    }
                    register!string;
                    //register!uint;
                    //register!int;
                    register!long;
                    
                    static foreach (fieldName ; c.fieldNames) {
                        {
                            mixin("alias f = c." ~ fieldName~";");
                            alias fieldType = typeof(f);
                            debug {
                                import std.conv;
                                sharedLog.info("param: " ~ typeid(fieldType).to!string ~ " " ~ fieldName);
                            }
                            register!fieldType(fieldName);
                        }
                    }
                }
            }
        }
    }
}

unittest {
    class MyClass {
    }
    
    @component
    class MyModule {
        @component
        public MyClass getMyClass() {
            return new MyClass;
        }    
    }
    debug {
        sharedLog.info("Starting component unittest.");
    }
    auto injector = newInjector!MyModule;
    assert(injector !is null);
    auto my = injector.resolve!MyClass;
    assert(my !is null);
}

unittest {
    alias param = Tuple!(
        string,"name",
        uint,"age"
    );    
    debug {
        sharedLog.info("Starting injector parameters unittest.");
    }
    auto injector = newInjector!param;
    assert(injector !is null);
    auto name = injector.resolve!string("name");
    auto age = injector.resolve!uint("age");
}

