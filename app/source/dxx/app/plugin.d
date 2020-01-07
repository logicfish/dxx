/++
This module managed dynamic loading of shared libraries as Plugins.

The plugin uses the runtime information from the framework to enforce
version consistency.

+/
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
module dxx.app.plugin;

private import std.experimental.logger;
private import std.exception;

//private import hunt.cache;

private import dxx.util;
private import dxx.sys.loader;

private import dxx.app.component;
private import dxx.app.extension;
private import dxx.app.platform;
private import dxx.app.properties;
private import dxx.app.services;

struct PluginDependency {
    string id;
    string verRange;
    bool optional;
}

struct PluginDescriptor {
    string id;
    string pluginVersion;
    string name;
    string pluginDoc;
    uint runLevel;
    string[string] attr;

    PluginDependency[] dependencies;
    ExtensionPointDesc[]* extensionPoints;
    ExtensionDesc[]* extensions;
}

/++
This struct is passed as the user data and passed to the exported methods
in the shared library, as defined by the `reloaded` framework.

Most of the fields are initilised by the host platform; several however
are initialised by the plugin platform.
++/
struct PluginContext {
  // These parts filled in by the kernel
    string delegate(string id) shared platformGetString;
    string[] delegate(string id) shared platformGetStrings;
    void delegate(string id,string value) shared platformSetString;
    void delegate(string id,string[] value) shared platformSetStrings;

    void delegate (string[] typeId,void delegate (ServiceNotification),string[string]) shared platformAddServiceListener;
    void delegate ( void delegate (ServiceNotification) ) shared platformRemoveServiceListener;

    ServiceRegistration delegate(string[] typeId,void*) shared registerService;
    void delegate(ServiceRegistration reg) shared unregisterService;
    //void delegate(ServiceRegistration reg) shared platformUpdateRegistration;

    ServiceReference delegate (string typeId) lookupServiceReference;
    ServiceReference[] delegate (string typeId) lookupServiceReferences;
    void* delegate(ServiceReference) lookupService;
    void delegate(ServiceReference) releaseServiceReference;

    void* delegate(string id) shared platformCreateInstance;
    void delegate(void*) shared platformDestroyInstance;

    PluginDescriptor* desc;   /// This part filled in by the plugin.
    void* delegate(string id) shared pluginCreateInstance; /// ditto
    void delegate(void*) shared pluginDestroyInstance; /// ditto
}

/++
Manages a single plugin (dynamic shared library).
++/
class PluginLoader {
    PluginContext ctx;
    PluginDescriptor _desc;
    Loader loader;
    alias loader this;

    static auto pluginFileName(string name,string path) {
      version(Windows) {
          return path ~ "/" ~ name ~ ".dll";
      } else {
          return path ~ "/lib" ~ name ~ ".so";
      }

    }
    void load(string path) {
      debug(Plugin) {
          MsgLog.info("PluginLoader load "  ~ path);
      }
      enforce(loader is null);
      loader = Loader.loadModule(path,&ctx);
      enforce(loader);
      _desc = *pluginContext.desc;
      pluginContext.desc = &_desc;
      auto pl = cast(shared(PluginLoader))this;
      pluginContext.platformCreateInstance = &pl.createInstance;
      pluginContext.platformDestroyInstance = &pl.destroyInstance;
      pluginContext.platformGetString = &pl.getString;
      pluginContext.platformGetStrings = &pl.getStrings;
      pluginContext.platformSetString = &pl.setString;
      pluginContext.platformSetStrings = &pl.setStrings;
//      pluginContext.platformSetProperty = &pl.setProperty;
    }
    void load(string name,string path) {
        auto p = pluginFileName(name,path);
        this.load(p);
    }
    inout ref
    auto desc() {
        return _desc;
    }
    inout ref
    auto pluginContext() {
        return ctx;
    }
    shared void* createInstance(string id) {
        auto a = TypeInfo_Class.find(id).create;
        // TODO use the injector lookup...
        return cast(void*)a;
    }
    void destroyInstance(void* t) shared {
        destroy(t);
    }
    string getString(string id) shared {
      return Properties.__("plugins." ~ pluginId ~ "." ~ id);
    }
    string[] getStrings(string id) shared {
      return Properties.___("plugins." ~ pluginId ~ "." ~ id);
    }
    void setString(string id,string value) shared {
      Properties.assign!string("plugins." ~ pluginId ~ "." ~ id,value);
    }
    void setStrings(string id,string[] value) shared {
      Properties.assign!(string[])("plugins." ~ pluginId ~ "." ~ id,value);
    }
    /* ServiceRegistration registerService(string[] typeId,void* svc) shared {
      enforce(typeId.length > 0);
      foreach(t;typeId) {
        shared(Registration) reg = new shared(Registration)(pluginId);
        reg.typeId = t;
        reg.service = cast(shared(void*))svc;
        getRegistry.put!(shared(Registration))(reg.fullyQualifiedIdentifier,reg);
      }
    }
    void unregisterService(ServiceRegistration reg) shared {
      //getRegistry.remove(pluginId ~ "." ~ reg.id);
      auto r = cast(shared(Registration*))reg._handle;
      if(r !is null) {
        getRegistry.remove(r.fullyQualifiedIdentifier);
      }
    }
    ServiceReference lookupServiceReference(string typeId) shared {
      auto r = getRegistry.get_ex!Registration(typeId);
      if(!r.isnull) {
        return r.createRef;
      }
    }
    void* lookupService(ServiceReference reference) shared {
    }
    static auto getRegistry() {
      auto manger = Properties.resolve!CacheManger;
      static UCache registry;
      if(registry is null) {
        registry = manger.getCache("serviceRegistry");
        if(registry is null) {
          registry = manger.createCache("serviceRegistry");
        }
      }
      return registry;
    } */
    auto pluginId() shared {
      return (cast(shared(PluginDescriptor))_desc).id;
    }
}

class PluginRuntime(PluginType : Plugin,Param...) : PlatformRuntime!(Param) {
    void registerPluginComponents(InjectionContainer injector) {
        debug(Plugin) {
            sharedLog.info("registerPluginComponents()");
        }
        new PluginDefault.ModuleListener().register;
        injector.register!(Plugin,PluginType);
        registerExtensionPoints();
        registerExtensions();
    }
    override void registerAppDependencies(InjectionContainer injector) {
        debug(Plugin) {
            sharedLog.trace("registerAppDependencies()");
        }
        super.registerAppDependencies(injector);
        registerPluginComponents(injector);
    }
    void registerExtensionPoints() {
      debug(Plugin) {
          sharedLog.trace("registerExtensionPoints()");
      }
    }
    void registerExtensions() {
      debug(Plugin) {
          sharedLog.trace("registerExtensions()");
      }
    }
}

mixin template registerPlugin(T : PluginRuntime!(P,Param),P : Plugin,Param ...) {
    version(DXX_Plugin) {
        mixin registerComponent!(T);
    }
}

interface PluginActivator {
    void activate(PluginContext* ctx);
    void deactivate(PluginContext* ctx);
}

interface Plugin {
//    void init(PluginDescriptor* pluginData);
    enum State {
        UNINSTALLED,INSTALLED,LOADED,INITIALIZED,STARTED,STOPPED,DEINITIALIZED
    }
    const(PluginDescriptor)* descr();
    void init();
    void deinit();
    PluginActivator activator();
}

abstract class PluginDefault : Plugin {
    static __gshared Plugin INSTANCE;
    static __gshared PluginDescriptor DESCR;
    static bool instantiated = false;

    PluginActivator _activator;

    ExtensionDesc[] extensions;
    ExtensionPointDesc[] extensionPoints;

    static void setDescr(PluginDescriptor desc) {
        DESCR = desc;
    }
    static auto getInstance() {
        if(!instantiated) {
            synchronized(PluginDefault.classinfo) {
                if(!INSTANCE) {
                    INSTANCE = resolveInjector!Plugin;
                }
            }
            instantiated = true;
        }
        return INSTANCE;
    }
    //static Plugin getInstance() {
    //    if(INSTANCE is null) {
    //        INSTANCE = resolveInjector!Plugin;
    //    }
    //    return INSTANCE;
    //}
    static class ModuleListener : ModuleNotificationListener {
        override shared void onInit(Module.ModuleEvent* event) {
            debug(Plugin) {
                info("onInit");
            }
            event.mod.data!(PluginContext).desc = &DESCR;
            //event.mod.data!(PluginContext).desc.extensionPoints = &extensionPoints;
            //event.mod.data!(PluginContext).desc.extensions = &extensions;
            event.mod.data!(PluginContext).pluginCreateInstance = &createInstance;
            event.mod.data!(PluginContext).pluginDestroyInstance = &destroyInstance;
            getInstance.init;
        }
        override shared void onDeinit(Module.ModuleEvent* event) {
            debug(Plugin) {
                info("onDeinit");
            }
        }
        override shared void onLoad(Module.ModuleEvent* event) {
            debug(Plugin) {
                info("onLoad");
            }
        }
        override shared void onUnload(Module.ModuleEvent* event) {
            debug(Plugin) {
                info("onUnload");
            }
            if(getInstance.activator !is null) {
                getInstance.activator.deactivate(event.mod.data!PluginContext);
            }
        }
        override shared void onUpdate(Module.ModuleEvent* event) {
            debug(Plugin) {
                info("onUpdate");
            }
            if(getInstance.activator !is null) {
                getInstance.activator.activate(event.mod.data!PluginContext);
            }
        }
        shared void* createInstance(string id) {
            auto a = TypeInfo_Class.find(id).create;
            // TODO use the injector lookup...
            return cast(void*)a;
        }
        shared void destroyInstance(void* t) {
            destroy(t);
        }
    }

    this() {
      DESCR.extensionPoints = &extensionPoints;
      DESCR.extensions = &extensions;
    }
    override void init() {
        debug(Pugin) {
            MsgLog.info("init");
            MsgLog.info(descr.id);
        }
    }
    override void deinit() {
        debug(Pugin) {
            MsgLog.info("deinit");
            MsgLog.info(descr.id);
        }
    }
    override PluginActivator activator() {
        debug(Pugin) {
            MsgLog.info("activator");
            MsgLog.info(descr.id);
        }
        return _activator;
    }
    void activator(PluginActivator a) {
        _activator = a;
    }

    override const(PluginDescriptor)* descr() {
        return &DESCR;
    }

}

mixin template pluginMain() {
    version(unittest) {
    } else {
        version(Windows) {
            private import core.sys.windows.dll;
            mixin SimpleDllMain;
        } else {
        }
    }
}
