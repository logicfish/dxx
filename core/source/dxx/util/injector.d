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
private import std.variant;
private import std.string : indexOf;
private import std.json;

private import aermicioi.aedi;
//private import aermicioi.aedi_property_reader;

private import dxx.constants;
private import dxx.util.ini;
private import dxx.util.config;

alias component = aermicioi.aedi.component;
alias autowired = aermicioi.aedi.autowired;
alias localInjector = InjectionContainer.getInstance;

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

    void terminate() {
      synchronized(InjectionContainer.classinfo) {
          if(instantiated) {
            debug(Injector) {
              sharedLog.info("terminating");
            }
            _container.terminate();
          }
          if(INSTANCE is this) {
            INSTANCE = null;
            instantiated = false;
          }
      }
    }
    auto instantiate() {
        debug(Injector) {
            sharedLog.info("instantiating");
        }
        return _container.instantiate;
    }
    //abstract void load(T : DocumentContainer!X, X...)(T container);
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
                    sharedLog.info("Scanning prototype ",typeid(c));
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
        /*version(DXX_Developer) {
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

        }*/
        /*auto cont = container(
          prototype
        );
        auto __j = loadJson("resources/dxx.json");

        foreach (c; cont) {
            load(c,__j);
        }
        return cont;*/
        auto cont = values;
        version(DXX_Developer) {
          //auto __j = loadJson("resources/dxx-dev.json");
          load(cont,loadJson("resources/dxx-dev.json"));
        } else version(Unittest) {
          //auto __j = loadJson("resources/dxx-ut.json");
          load(cont,loadJson("resources/dxx-ut.json"));
        } else {
          //auto __j = loadJson("resources/dxx.json");
          load(cont,loadJson("resources/dxx.json"));
          load(cont,loadJson("dxx.json"));
        }
        // parse the environment
        // parse the command line
        load(cont,cast(string[])runtimeConstants.argsApp.dup);
        return cont;
    }
    auto loadJson(string pathOrData) {
      import std.file : exists, readText;
      if (pathOrData.exists) {
        debug(trace) trace("Loading json from ", pathOrData);
        pathOrData = pathOrData.readText();
      }
      try {
        return parseJSON(pathOrData);
      } catch(Exception e) {
        return parseJSON("{}");
      }
    }
    string[] toStringArray(const(JSONValue)[] ar) {
      string[] res;
      foreach(v;ar) {
        debug(Injector) {
            sharedLog.trace("array ",v);
        }
        res ~= v.str;
      }
      return res;
    }
    Variant readValue(const(JSONValue) j,string name) {
        auto v = LocalConfig.get(name);
        if(v != null) return v;
        //return null;
        // scan env
        // scan args
        // scan properties
        auto inx = name.indexOf('.');
        if(inx != -1) {
          string n = name[0..inx];
          if(const(JSONValue)* x = n in j) {
            return readValue(*x,name[inx+1..$]);
          }
        }
        if(const (JSONValue)* val = name in j) {
          debug(Injector) {
            sharedLog.trace(name," = ",*val);
          }
          /*static if(is(_T == int)) {
            return Variant(val.integer);
          } else if(is(_T == uint)) {
            return Variant(val.integer);
          } else if(is(_T == bool)) {
            return Variant(val.boolean);
          } else if (is(_T == immutable(char)[])) {
            return Variant(val.str);
          } else if (is(_T == string[])) {
            string[] vals;
            vals = toStringArray(val.array);
            return Variant(vals);
          }*/
          switch(val.type) {
            case(JSONType.integer):
              return Variant(val.integer);
            case(JSONType.true_):
            case(JSONType.false_):
              return Variant(val.boolean);
            case(JSONType.string):
              return Variant(val.str);
            case(JSONType.array):
              string[] vals;
              vals = toStringArray(val.array);
              return Variant(vals);
            default:
              return Variant(null);
          }

        }
        /*} else {
          static if(is(_T == int)) {
            return Variant(-1);
          } else if(is(_T == bool)) {
            return Variant(false);
          } else if (is(_T == string)) {
            return Variant("");
          } else if (is(_T == string[])) {
            string[] x = [];
            return Variant(x);
          }
        }*/
        return Variant(null);
    }
    //void load(T : DocumentContainer!X, X...)(T container) {
    void load(T)(T container,const(JSONValue) __j) {
      load(container,x=>readValue(__j,x));
    }
    void load(T)(T container,string[] cmd) {
      //load(container,x=>readValue(__j,x));
    }
    void load(T)(T container,Variant delegate (string) getVal) {
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
                                  sharedLog.trace("field: " ~ typeid(fieldType).to!string ~ " " ~ fieldName);
                              }
                              static if(isTuple!fieldType) {
                                _reg!(fieldName ~ ".",fieldType)();
                              } else {
                                //auto v = readValue(__j,fieldName);
                                auto v = getVal(fieldName);
                                if(v.peek!fieldType !is null) {
                                  debug(Injector) {
                                    sharedLog.trace(fieldName," = ",v.get!fieldType);
                                  }
                                  register!fieldType(v.get!fieldType,fieldName);
                                }
                              }
                            }
                          }
                      }
                    }
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
    terminateInjector;
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
    terminateInjector;
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
    terminateInjector;
    auto injector = newInjector!param;
    assert(injector !is null);
    auto name = injector.resolve!string("param.name");
    auto age = injector.resolve!long("param.age");
}
