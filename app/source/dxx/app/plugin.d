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

private import dxx.util;
private import dxx.app.component;

private import dxx.sys.loader;

struct PluginDescriptor {
    string id;
    string pluginVersion;
    string name;
    string pluginDoc;
    string[string] attr;
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
        mixin registerComponent!(PluginComponents!(P,Param));
    }
}

interface PluginActivator {
    void activate(PluginContext* ctx);
    void deactivate(PluginContext* ctx);
}

interface Plugin {
//    void init(PluginDescriptor* pluginData);
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
    }

    //shared static this() {
    //    new ModuleListener().register;
    //}
    this() {
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

