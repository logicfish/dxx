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
module dxx.app.plugin;

private import std.experimental.logger;
private import std.exception;

private import dxx.util;
private import dxx.sys.loader;

private import dxx.app.component;
private import dxx.app.extension;
private import dxx.app.platform;

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

struct PluginContext {
    PluginDescriptor* desc;
    void* delegate(string id) shared pluginCreateInstance;
    void delegate(void*) shared pluginDestroyInstance;
}

class PluginLoader {
    PluginContext ctx;
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
      loader = Loader.loadModule(path,&ctx);
      enforce(loader);
    }
    void load(string name,string path) {
        auto p = pluginFileName(name,path);
        this.load(p);
    }
    inout ref
    auto desc() {
        return ctx.desc;
    }
    inout ref
    auto pluginContext() {
        return ctx;
    }
}

class PluginRuntime(PluginType : Plugin,Param...) : PlatformRuntime!(Param) {
    void registerPluginComponents(InjectionContainer injector) {
        injector.register!(Plugin,PluginType);
        new PluginDefault.ModuleListener().register;
    }
    override void registerAppDependencies(InjectionContainer injector) {
        debug(Plugin) {
            import std.experimental.logger;
            sharedLog.info("registerAppDependencies()");
        }
        super.registerAppDependencies(injector);
        registerPluginComponents(injector);
    }
}

mixin template registerPlugin(P : Plugin,Param ...) {
    version(DXX_Plugin) {
        mixin registerComponent!(PluginRuntime!(P,Param));
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
            unregister;
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
            // TODO use injector
            return cast(void*)a;
        }
        shared void destroyInstance(void* t) {
            destroy(t);
        }
    }

    //shared static this() {
    //    new ModuleListener().register;
    //}
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
