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
module dxx.sys.loader;

private import std.stdio : writeln;
private import core.stdc.stdlib : system;
//private import core.thread;

private import reloaded : Reloaded, ReloadedCrashReturn;

private import dxx.sys.constants;
//private import dxx.packageVersion;
private import dxx.util.notify;



struct ModuleData
{
    const(RTConstants)* hostRuntime;
    const(RTConstants)* moduleRuntime;
    void* modData;
}

class Loader {
    @property
    const(string) path;

    shared(ModuleData) moduleData;
    Reloaded script;

    this(const(string) path,void* data) {
        //this.moduleData.libVersion = packageVersion;
        this.moduleData.hostRuntime = &RTConstants.runtimeConstants;
        this.moduleData.modData = cast(shared(void*))data;
        this.path = path;
        script = Reloaded();
    }
    void load() {
        script.load(path, moduleData);
        mixin ReloadedCrashReturn;
    }
    void update() {
        script.update;
    }
    void update(void* data) {
        this.moduleData.modData = cast(shared(void*))data;
        update;
    }
    static auto loadModule(const(string) path,void* data) {
        auto l = new Loader(path,data);
        l.load;
        return l;
    }
}

final class Module : SyncNotificationSource {
    struct ModuleEvent {
        enum Type {
            Init,
            Deinit,
            Load,
            Unload,
            Update
        }
        Type eventType;
        shared(Module) mod;
    };
    ModuleData* moduleData;
    static __gshared shared(Module) INSTANCE;

    version(DXX_Module) {
        shared static this() {
            if(INSTANCE is null) {
                INSTANCE = new shared(Module);
            }
        }
    }

    template data(alias T) {
        //alias data = moduleData.data!T;
        auto ref shared data() {
            return cast(T*)moduleData.modData;
        }
    }
    
    private shared this() {}
    
    private nothrow shared void sendModuleEvent(alias T)() {
        auto m = ModuleEvent(T,this);
        this.send!ModuleEvent(&m);
    }
    private shared void init() {
        sendModuleEvent!(ModuleEvent.Type.Init);
    }
    private shared void deinit() {
        sendModuleEvent!(ModuleEvent.Type.Deinit);
    }
    private shared void load() {
        sendModuleEvent!(ModuleEvent.Type.Load);
    }
    private shared void unload() {
        sendModuleEvent!(ModuleEvent.Type.Unload);
    }
    private shared void update() {
        sendModuleEvent!(ModuleEvent.Type.Update);
    }
}


class ModuleNotificationListener : NotificationListener {
    override shared void handleNotification(void* t) {
        Module.ModuleEvent* event = cast(Module.ModuleEvent*)t;
        final switch(event.eventType) {
            case Module.ModuleEvent.Type.Init: 
            onInit(event); 
            break;
            case Module.ModuleEvent.Type.Deinit:
            onDeinit(event); 
            break;
            case Module.ModuleEvent.Type.Load:
            onLoad(event); 
            break;
            case Module.ModuleEvent.Type.Unload:
            onUnload(event); 
            break;
            case Module.ModuleEvent.Type.Update:
            onUpdate(event); 
            break;
        }
    }
    shared void onInit(Module.ModuleEvent* event){}
    shared void onDeinit(Module.ModuleEvent* event){}
    shared void onLoad(Module.ModuleEvent* event){}
    shared void onUnload(Module.ModuleEvent* event){}
    shared void onUpdate(Module.ModuleEvent* event){}
    void register() {
        version(DXX_Module) {
            Module.INSTANCE.addNotificationListener(cast(shared(NotificationListener))this);
        }
    }
    void unregister() {
        version(DXX_Module) {
            Module.INSTANCE.removeNotificationListener(cast(shared(NotificationListener))this);
        }
    }
}


version(DXX_Module) {
    
    extern(C):

    import core.stdc.stdio : printf;

    void load( void* userdata ) {
        printf("load\n");
        Module.INSTANCE.moduleData = cast(shared(ModuleData)*) userdata;
        Module.INSTANCE.load;
    }

    void unload(void* userdata) {
        Module.INSTANCE.moduleData = cast(shared(ModuleData)*) userdata;
        printf("unload\n");
        Module.INSTANCE.unload;
    }

    void init(void* userdata) {
        Module.INSTANCE.moduleData = cast(shared(ModuleData)*) userdata;
        Module.INSTANCE.moduleData.hostRuntime = &RTConstants.runtimeConstants;
        printf("init\n");
        Module.INSTANCE.init;
    }
    void uninit(void* userdata){
        Module.INSTANCE.moduleData = cast(shared(ModuleData)*) userdata;
        printf("uninit\n");
        Module.INSTANCE.deinit;
    }

    void update() {
        printf("update\n");
        Module.INSTANCE.update;
    }

}
