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

private import dxx.util;

private import dxx.util;
private import dxx.app.component;

private import dxx.sys.loader;

struct PluginDescriptor {
    string id;
    string semVer;
    string name;
    string pluginDoc;
    string[string] properties;
}

struct PluginContext {
    PluginDescriptor* desc;
}

final class PluginLoader {
    PluginContext ctx;
    Loader loader;
    alias loader this;

    void load(const(string) path) {
        debug(Plugin) {
            MsgLog.info("PluginLoader " ~ path);
        }
        loader = Loader.loadModule(path,&ctx);
    }
}

class PluginComponents(PluginType : Plugin,Param...) : RuntimeComponents!(Param) {
    void registerPluginComponents(InjectionContainer injector) {
    }
    override void registerAppDependencies(InjectionContainer injector) {
        debug(Plugin) {
            import std.experimental.logger;
            sharedLog.info("registerAppDependencies()");
        }
        super.registerAppDependencies(injector);
        injector.register!(Plugin,PluginType);
        registerPluginComponents(injector);
    }
}

mixin template registerPlugin(P : Plugin,Param ...) {
    version(DXX_Plugin) {
        mixin registerComponent!(PluginComponents!(P,Param));
    }
}

interface Plugin {
//    void init(PluginDescriptor* pluginData);
    const(PluginDescriptor)* descr();
    void init();
    void activate(PluginContext* ctx);
    void deactivate(PluginContext* ctx);
}

abstract class PluginDefault : Plugin {
    static __gshared Plugin INSTANCE;
    static __gshared PluginDescriptor DESCR;
    static bool instantiated = false;

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
            debug {
                MsgLog.info("onInit");
            }
            event.mod.data!(PluginContext).desc = &DESCR;
            getInstance.init;
        }
        override shared void onDeinit(Module.ModuleEvent* event) {
            debug {
                MsgLog.info("onDeinit");
            }
        }
        override shared void onLoad(Module.ModuleEvent* event) {
            debug {
                MsgLog.info("onLoad");
            }
            getInstance.activate(event.mod.data!PluginContext);
        }
        override shared void onUnload(Module.ModuleEvent* event) {
            debug {
                MsgLog.info("onUnload");
            }
            getInstance.deactivate(event.mod.data!PluginContext);
            unregister;
        }
        override shared void onUpdate(Module.ModuleEvent* event) {
            debug {
                MsgLog.info("onUpdate");
            }
        }
    }

    shared static this() {
        new ModuleListener().register;
    }
    this() {
    }
    void init() {
        debug(Pugin) {
            MsgLog.info("init");
            MsgLog.info(descr.id);
        }
    }

    void activate(PluginContext* ctx) {
        debug(Pugin) {
            MsgLog.info("activate");
            MsgLog.info(descr.id);
        }
    }

    void deactivate(PluginContext* ctx) {
        debug(Pugin) {
            MsgLog.info("deactivate");
            MsgLog.info(descr.id);
        }
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

