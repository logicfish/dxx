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

private import dxx.sys.constants;
private import dxx.packageVersion;


private import std.stdio : writeln;
private import core.stdc.stdlib : system;
//private import core.thread;

private import reloaded : Reloaded, ReloadedCrashReturn;


struct ModuleData
{
    const(RTConstants)* hostRuntime;
    const(string) libVersion;
    void* userData;
}

class Loader {
    @property
    const(string) path;

    ModuleData moduleData;
    Reloaded script;

    this(const(string) path,void* userData) {
        this.moduleData.libVersion = packageVersion;
        this.moduleData.hostRuntime = &RTConstants.runtimeConstants;
        this.moduleData.userData = userData;
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
    void update(void* userData) {
        this.moduleData.userData = userData;
        update;
    }
    static auto loadModule(const(string) path,void* userData) {
        auto l = new Loader(path,userData);
        l.load;
        return l;
    }
}

version(DXX_Module) {
    
    final class Module {
        ModuleData* moduleData;
        static __gshared Module thisModule;

        shared static this() {
            thisModule = new Module;
        }
    }
    
    
    extern(C):

    import core.stdc.stdio : printf;

    void load( void* userdata ) {
        printf("load\n");
        Module.thisModule.moduleData = cast(ModuleData*) userdata;
    }

    void unload(void* userdata) {
        Module.thisModule.moduleData = cast(ModuleData*) userdata;
        printf("unload\n");
    }

    void init(void* userdata) {
        Module.thisModule.moduleData = cast(ModuleData*) userdata;
        printf("init\n");
    }
    void uninit(void* userdata){
        Module.thisModule.moduleData = cast(ModuleData*) userdata;
        printf("uninit\n");
    }

    void update() {
        printf("update\n");
    }

}
