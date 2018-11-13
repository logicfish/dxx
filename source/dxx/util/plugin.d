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
module dxx.util.plugin;

private import dxx.sys.loader;

struct PluginDescriptor {
    string id;
    string semVer;
    string name;
    string pluginDoc;
}

struct PluginContext {
    PluginDescriptor* desc;
}

class PluginLoader {
    PluginContext ctx;
    Loader loader;
    alias loader this;

    this(const(string) path) {
        loader = Loader.loadModule(path,&ctx);
    }
}

interface Plugin {
//    void init(PluginDescriptor* pluginData);
    const(PluginDescriptor)* descr();
    void init();
    void activate(PluginContext* ctx);
    void deactivate(PluginContext* ctx);
}

class PluginDefault : Plugin {
    static __gshared PluginDefault INSTANCE;
    PluginDescriptor pluginDescr;
    
    class ModuleListener : ModuleNotificationListener {
        override shared void onInit(Module.ModuleEvent* event){
            INSTANCE.init;
        }
        override shared void onDeinit(Module.ModuleEvent* event){}
        override shared void onLoad(Module.ModuleEvent* event){
            event.mod.data!(PluginContext).desc = &INSTANCE.pluginDescr;
            INSTANCE.activate(event.mod.data!PluginContext);
        }
        override shared void onUnload(Module.ModuleEvent* event){
            INSTANCE.deactivate(event.mod.data!PluginContext);
        }
        override shared void onUpdate(Module.ModuleEvent* event){}
    }

    ModuleListener listener;

    this() {
        if(INSTANCE is null) {
            INSTANCE = this;
        }
        listener = new ModuleListener;
        version(DXX_Plugin) {
            listener.register;
        }
    }
    void init() {
    }

    void activate(PluginContext* ctx) {
    }

    void deactivate(PluginContext* ctx) {
    }
    
    override const(PluginDescriptor)* descr() {
        return &pluginDescr;
    }
}

