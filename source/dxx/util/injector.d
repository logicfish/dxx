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

private import aermicioi.aedi;
private import aermicioi.aedi_property_reader;

private import dxx.util.ini;
//private import dxx.util.storage;

//static Variant[string] readInjectorProperties(File* f) {
//    Variant[string] res;
//    return res;
//}
//
//static void registerInjectorProperties(Variant[string] properties) {
    //DefaultInjector._DEFAULT_CONTAINER.each!(c=>{
    //    with(c.configure) {
    //        properties.each!((k,v)=>{
    //            if(v.type == typeid(string)) {
    //            }
    //        });
    //    }
    //});
    //properties.keys.each!((k)=>{
//	    if(v.type == typeid(string)) {
	//    	DefaultInjector.register!string(k);
//        }
//    });
//}

static auto resolveInjector(alias T,Arg...)(Arg arg) {
    return DefaultInjector._DEFAULT_INJECTOR.resolve!T(arg);
}

static auto newInjector(alias T)(AggregateContainer c = null) {
    if(DefaultInjector._DEFAULT_INJECTOR !is null) {
        return DefaultInjector._DEFAULT_INJECTOR;
    } else {
        return new ContextInjector!T(c);
    }
}

static T getInjectorProperty(T)(DefaultInjector i,string k) {
    return i.resolve!T(k);
}

static void setInjectorProperty(T)(DefaultInjector i,string k,T t) {
    i.register!T(t,k);
}

abstract class DefaultInjector {

    static __gshared DefaultInjector _DEFAULT_INJECTOR;

    @property
    AggregateContainer _container;
        
    //auto services(T)(T parent) {
    //    auto cont = container(
    //        singleton,
    //        prototype
    //    );
    //
    //    configureSingleton(cont[0]);
    //    scanPrototype(cont[1]);
    //    return cont;
    //}
    void services(T)(T parent) {
        auto s = singleton;
        auto p = prototype;

        configureSingleton(s);
        scanPrototype(p);

        parent.set(s,"singleton");
        parent.set(p,"prototype");    
        
    }        
    auto config() {
        auto cont = container(
          //singleton,
          //prototype,
          argument,
          env
          //xml("./config.xml"),
          //xml("~/.config/aedi-example/config.xml"),
          //xml("/etc/aedi-example/config.xml"),
          //json("./config.json"),
          //json("~/.config/aedi-example/config.json"),
          //json("/etc/aedi-example/config.json"),
          //sdlang("./config.sdlang"),
   	      //sdlang("~/.config/aedi-example/config.sdlang"),
          //sdlang("/etc/aedi-example/config.sdlang")
          //configFiles
           );
        foreach (c; cont) {
            load(c);
        }

        return cont;
    }
    abstract void scanPrototype(PrototypeContainer);
    abstract void configureSingleton(SingletonContainer);
    
    static void load(T : DocumentContainer!X, X...)(T container) {
        with (container.configure) {
            register!long("first");
            register!double("second");
            register!string("third");
            //register!Component("");
            //register!Component("json");
            //register!Component("xml");
            //register!Component("sdlang");
            //register!Component("yaml");
                
        }
    }        
        
    //shared static this() {
    //    debug {
    //        sharedLog.info("Creating shared container.");
    //    }
    ////    //_DEFAULT_CONTAINER = prototype();
    ////    //auto c = container(
	////    //    argument(),
    // ////	env()
    ////    //    );
    ////    //auto c = aggregate(config, "parameters");
    ////    //c.set(services(c), "services");
    ////    //_DEFAULT_CONTAINER = c;
    ////    //scope(exit) _DEFAULT_CONTAINER.terminate();
    ////    
    //}
    //this(AggregateContainer _c = _DEFAULT_INJECTOR._container) {
    this(AggregateContainer _c = null) {
        debug {
            sharedLog.info("Creating injector.");
        }
        if(_c !is null) {
            _container = _c;
        } else {
            debug {
                sharedLog.info("Creating injection container.");
            }
           //auto c = container(
           //    argument(),
           //	env()
           //);
           auto c = aggregate(config, "parameters");
           services(c);
           _container = c;
        }
        if(_DEFAULT_INJECTOR is null) {
            _DEFAULT_INJECTOR = this;
        }
    }
    //void registerProperties(string[string] properties) {
    //}
//        auto resolve(alias T)() {
//            return _container.locate!T;
//        }
    auto resolve(T,Arg ...)(Arg arg) {
        return _container.locate!T(arg);
    }
//        void register(T...)() {
//            _container.register!T;
//        }
    void register(T...)(const(string) arg) {
        with(_container.configure("prototype")) {
        //    with(configure("prototye")) {
                register!T(arg);
        //    }
        }
    }
    void register(T)(ref T t,const(string) arg) {
        with(_container.configure("singleton")) {
            register!T(t,arg);
        }
    }
    //void set(string k,string v) {
    //    with(_container.configure("prototype")) {
    //    }        
    //}
    void setProperty(T)(string k,T v) {
        with(container.configure("parameters")) {
            register!T(v,k);
        }
    }    
    T getProperty(T)(string k) {
        return _container.locate!T(k);
    }   
    //auto configure() {
    //    return _container.configure;
    //}
    auto instantiate() {
        debug {
            sharedLog.info("instantiating.");
        }
        scope(exit) _container.terminate();
        return _container.instantiate;
    }
}


final class ContextInjector(C...) : DefaultInjector {
    this(AggregateContainer c = null) {
        super(c);
        //c.scan!C;
        //foreach (subcontainer; c) {
//	        with (subcontainer.configure) {
//			//register!ushort("http.port");
//			//register!(string[])("http.listen");
//			//register!string("http.host");
//			//register!bool("http.compression");
//			//register!string("log.access.file");
//			//register!string("log.access.format");
//			//register!bool("log.access.console");
//			//register!string("route.index");
//			//register!string("route.about");
//			//register!string("route.public");
//		    }
        //}       
    }
    override void scanPrototype(PrototypeContainer p) {
        static foreach(c;C) {
            debug {
                import std.conv;
                sharedLog.info("Scanning prototype: " ~ typeid(c).to!string);
            }
            p.scan!c;
        }
    }
    override void configureSingleton(SingletonContainer) {
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
        sharedLog.info("Starting unittest.");
    }
    auto injector = newInjector!MyModule;
    assert(injector !is null);
    auto my = injector.resolve!MyClass;
    assert(my !is null);
}

