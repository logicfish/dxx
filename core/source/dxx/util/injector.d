/**
Copyright: 2018 Mark Fisher

License:
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
/**
 * A wrapper that creates injection tools for your project.
 * The settings are passed as template parameters to the
 * class LocalInjector which you instantiate using the
 * static method newInjector.
 * Only one instance of LocalInjector is created;
 * subsequent invocations of newInjector will return
 * the existing instance, and the parameters will be ignored.
 * The parameters to newInjector are parsed:
 * Class parameters are passed to the
 * wrapped container using the "scan" method.
 * Tuple parameters
 * are parsed and converted into properties which
 * are loaded at runtime from "dxx.json".
 * TODO allow for the property filenames to be overridden.
 **/
module dxx.util.injector;

private import std.experimental.logger;
private import std.stdio;
private import std.process : environment;
private import std.typecons;

private import aermicioi.aedi;
private import aermicioi.aedi_property_reader;

private import dxx.constants;
private import dxx.util.ini;
private import dxx.util.config;

alias component = aermicioi.aedi.component;
alias localInjector = InjectionContainer.INSTANCE;

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
    synchronized(InjectionContainer.classinfo) {
      if(InjectionContainer.getInstance is null) {
        new LocalInjector!(T,V)(c);
      }
    }
    return InjectionContainer.getInstance;
}

static void terminateInjector() {
    synchronized(InjectionContainer.classinfo) {
        if(InjectionContainer.getInstance) {
            InjectionContainer.getInstance.terminate;
        }
    }
}

abstract class InjectionContainer {

    private static __gshared InjectionContainer INSTANCE;
    static bool instantiated = false;

    static auto ref getInstance() {
        //assert(INSTANCE !is null);
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

    this(AggregateContainer _c) {
        synchronized(InjectionContainer.classinfo) {
            if(!instantiated) {
                if(INSTANCE is null) {
                    services(_c);
                    _container = _c;
                    INSTANCE = this;
                }
                instantiated = true;
            }
        }
    }

    auto resolve(T,Arg ...)(Arg arg) {
        return _container.locate!T(arg);
    }

    void register(T...)(const(string) arg) {
        _container.configure("prototype").register!T(arg);
    }
    void register(T...)() {
        _container.configure("prototype").register!T();
    }
    void register(T)(ref T t,const(string) arg) {
        _container.configure("singleton").register!T(t,arg);
    }

    T getParam(T)(string k) {
        debug(Injector) {
            sharedLog.info("getParam ",k);
        }
        return _container.locate!T(k);
    }
    void terminate() {
        debug(Injector) {
            sharedLog.info("terminating");
        }
        _container.terminate();
    }
    auto instantiate() {
        debug(Injector) {
            sharedLog.info("instantiating");
        }
        return _container.instantiate;
    }
    abstract void load(T : DocumentContainer!X, X...)(T container);
}


final class LocalInjector(C...) : InjectionContainer {
    this(AggregateContainer c = null) {
        if(c is null) c = aggregate(config, "parameters");
        super(c);
    }
    override void scanPrototype(PrototypeContainer p) {
        static foreach(c;C) {
            static if(isTuple!c is false) {
                debug(Injector) {
                    pragma(msg,"scanning prototype: ");
                    pragma(msg,c);
                }
                p.scan!c;
            }
        }
    }
    override void configureSingleton(SingletonContainer) {
    }

    auto config() {
        debug(Injector) {
            sharedLog.info("Injector config");
        }
        version(DXX_Developer) {
          auto cont = container(
            argument,
            env,
            //json("./dxx-dev.json"),
            json("./resources/dxx-dev.json"),
            json(RTConstants.constants.appDir ~ "/../../resources/dxx-dev.json"),
            //json("./dxx.json"),
            //json("./resource/dxx.json"),
            //json(RTConstants.constants.appDir ~ "/../dxx.json")
             );
        } else {
          auto cont = container(
            argument,
            env,
            json("./resources/dxx.json"),
            json(RTConstants.constants.appDir ~ "/../resources/dxx.json")
            //json("/etc/aedi-example/config.json"),
            //configFiles
             );

        }
        foreach (c; cont) {
            load(c);
        }
        return cont;
    }
    void load(T : DocumentContainer!X, X...)(T container) {
        with (container.configure) {
            static foreach(c;C) {
                static if(isTuple!c) {
                    template _reg(alias n,alias T) {
                      void _reg() {
                          static foreach (name ; T.fieldNames) {
                            {
                              enum fieldName = n ~ name;
                              mixin("alias _f = c." ~ fieldName~";");
                              alias fieldType = typeof(_f);
                              debug(Injector) {
                                  import std.conv;
                                  //sharedLog.info("field: " ~ typeid(fieldType).to!string ~ " " ~ fieldName);
                                  pragma(msg,"field");
                                  pragma(msg,fieldType);
                                  pragma(msg,fieldName);
                              }
                              static if(isTuple!fieldType) {
                                _reg!(fieldName ~ ".",fieldType)();
                              } else {
                                register!fieldType(fieldName);
                              }
                            }
                          }
                      }
                    }

                    /*static foreach (fieldName ; c.fieldNames) {
                        {
                            mixin("alias f = c." ~ fieldName~";");
                            alias fieldType = typeof(f);
                            debug(Injector) {
                                import std.conv;
                                //sharedLog.info("field: " ~ typeid(fieldType).to!string ~ " " ~ fieldName);
                                pragma(msg,"field");
                                pragma(msg,fieldType);
                                pragma(msg,fieldName);
                            }
                            static if(isTuple!fieldType) {
                              _reg!(fieldType,fieldName);
                            } else {
                              register!fieldType(fieldName);
                            }
                        }
                    }*/
                    _reg!("",c)();
                }
                // Scan properties from the .ini file.
                // Make them all strings.
                iterateValuesF!(DXXConfig.keys)( (string fqn,string k,string v) {
                    register!string(k);
                } );
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
        long,"age",
        string[string],"properties"
    );
    debug {
        sharedLog.info("Starting injector tuple parameters unittest.");
    }
    auto injector = newInjector!param;
    assert(injector !is null);
    auto name = injector.resolve!string("name");
    auto age = injector.resolve!long("age");
}

unittest {
    struct Param {
      string name;
      long age;
      string[string] properties;
    }
    alias param = Tuple!(Param,"param");
    debug {
        sharedLog.info("Starting injector struct parameters unittest.");
    }
    auto injector = newInjector!param;
    assert(injector !is null);
    auto name = injector.resolve!string("param.name");
    auto age = injector.resolve!long("param.age");
}
