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

private import std.exception;
private import std.experimental.logger;

private import reloaded : Reloaded, ReloadedCrashReturn;

private import dxx.constants;
private import dxx.util.notify;
private import dxx.util.log;



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
        debug(Loader) {
            MsgLog.info("Loader " ~ path);
        }
        //this.moduleData.libVersion = packageVersion;
        this.moduleData.hostRuntime = &RTConstants.runtimeConstants;
        this.moduleData.modData = cast(shared(void*))data;
        this.path = path;
        script = Reloaded();
    }
    void load() {
        debug(Loader) {
            sharedLog.info("load " ~ path);
        }
        script.load(path, moduleData);
        mixin ReloadedCrashReturn;
    }
    void update() {
        debug(Loader) {
            sharedLog.info("load " ~ path);
        }
        script.update;
    }
    void update(void* data) {
        debug(Loader) {
            sharedLog.info("updated " ~ path);
        }
        this.moduleData.modData = cast(shared(void*))data;
        update;
    }
    static auto loadModule(const(string) path,void* data) {
        debug(Loader) {
            sharedLog.info("loadModule " ~ path);
        }
        auto l = new Loader(path,data);
        l.load;
        debug(Loader) {
            sharedLog.info("loaded " ~ path);
        }
        l.validate;
        return l;
    }
    void validate() {
        debug(Loader) {
            sharedLog.info("validate " ~ path);
            //sharedLog.info(moduleData.moduleRuntime.semVer);
            //sharedLog.info(moduleData.hostRuntime.semVer);
            sharedLog.info(moduleData.hostRuntime.libVersions);
        }
        enforce(moduleData.moduleRuntime);
        enforce(moduleData.moduleRuntime.checkVersion(RTConstants.constants.semVer));
        //enforce(RTConstants.runtimeConstants.checkVersion(moduleData.moduleRuntime.semVer));
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

    private static __gshared shared(Module) INSTANCE;
    static bool instantiated = false;
    static auto getInstance() {
        if(!instantiated) {
            synchronized(Module.classinfo) {
                if(!INSTANCE) {
                    debug(Module) {
                        sharedLog.info("new instance.");
                    }
                    INSTANCE = new shared(Module);
                }
            }
            instantiated = true;
        }
        return INSTANCE;
    }

    //version(DXX_Module) {
    //    shared static this() {
    //        if(INSTANCE is null) {
    //            INSTANCE = new shared(Module);
    //        }
    //    }
    //}

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
    shared void init() {
        //checkModuleVersion;
        debug(Module) { sharedLog.info("init"); }
        sendModuleEvent!(ModuleEvent.Type.Init);
    }
    shared void deinit() {
        debug(Module) { sharedLog.info("deinit"); }
        sendModuleEvent!(ModuleEvent.Type.Deinit);
    }
    shared void load() {
        debug(Module) { sharedLog.info("load"); }
        sendModuleEvent!(ModuleEvent.Type.Load);
    }
    shared void unload() {
        debug(Module) { sharedLog.info("unload"); }
        sendModuleEvent!(ModuleEvent.Type.Unload);
    }
    shared void update() {
        debug(Module) { sharedLog.info("update"); }
        sendModuleEvent!(ModuleEvent.Type.Update);
    }
}


class ModuleNotificationListener : NotificationListener {
    override shared void handleNotification(void* t) {
        Module.ModuleEvent* event = cast(Module.ModuleEvent*)t;
        debug(Module) {
            import std.conv;
            sharedLog.info("Notification:",event.eventType);
        }
        final switch(event.eventType) {
            case Module.ModuleEvent.Type.Init:
            onInit(event);
            break;
            case Module.ModuleEvent.Type.Deinit:
            onDeinit(event);
            unregister;
            break;
            case Module.ModuleEvent.Type.Load:
            onLoad(event);
            break;
            case Module.ModuleEvent.Type.Unload:
            onUnload(event);
            //unregister;
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
            Module.getInstance.addNotificationListener(cast(shared(NotificationListener))this);
        }
    }
    shared void unregister() {
        version(DXX_Module) {
            Module.getInstance.removeNotificationListener(cast(shared(NotificationListener))this);
        }
    }
}


//mixin template moduleMain() {
    version(DXX_Module) {

        import core.stdc.stdio : printf;
        import std.experimental.logger;
        import std.exception;
        import dxx.constants;

        extern(C):
        void load( void* userdata ) {
            debug(Module) { sharedLog.info("[module] load"); }
    //        Module.getInstance.moduleData = cast(shared(ModuleData)*) userdata;
    //        Module.getInstance.moduleData.moduleRuntime = &RTConstants.runtimeConstants;
            Module.getInstance.load;
        }

        void unload(void* userdata) {
    //        Module.getInstance.moduleData = cast(shared(ModuleData)*) userdata;
            debug(Module) { sharedLog.info("[module] unload"); }
            Module.getInstance.unload;
        }

        void init(void* data) {
            assert(data);
            debug(Module) { sharedLog.info("[module] init"); }

            auto moduleData = cast(shared(ModuleData)*)data;

            assert(moduleData.hostRuntime);

            Module.getInstance.moduleData = moduleData;
            moduleData.moduleRuntime = &RTConstants.runtimeConstants;
            //enforce(moduleData.hostRuntime.checkVersion());
            //enforce(moduleData.hostRuntime.checkVersion(moduleData.moduleRuntime.semVer));
            enforce(moduleData.hostRuntime.checkVersion(RTConstants.constants.semVer));

            Module.getInstance.init;
        }
        void uninit(void* userdata){
            Module.getInstance.moduleData = cast(shared(ModuleData)*) userdata;
            debug(Module) { sharedLog.info("[module] uninit"); }
            Module.getInstance.deinit;
        }

        void update() {
            debug(Module) { sharedLog.info("[module] update"); }
            Module.getInstance.update;
        }
    }
//}
