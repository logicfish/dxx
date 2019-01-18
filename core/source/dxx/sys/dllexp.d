//mixin template moduleMain() {
    version(DXX_Module) {

        import core.stdc.stdio : printf;
        import std.experimental.logger;
        import std.exception;
        import dxx.constants;

        import dxx.sys.loader;
        
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
