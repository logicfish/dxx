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
module dxx.app.platform;

private import std.exception;
private import std.typecons;

private import aermicioi.aedi;
private import hunt.cache;

private import dxx.util;

private import dxx.app;

private import dxx.app.resource;
private import dxx.app.document;
private import dxx.app.component;
private import dxx.app.workbench;
private import dxx.app.extension;


//interface DocumentResourceAdaptor {
    //DocumentType getDocType(FileResource);
//}

interface PlatformComponents {
    URIResolver getURIResolver();
    ResourceValidator getResourceValidator();
    ResourceContentProvider getResourceContentProvider();
    //DocumentResourceAdaptor getDocumentResourceAdaptor();

    public WorkflowRunner getWorkflowRunner();
    public PluginLoader getPluginLoader();
    public ExtensionsManager getExtensionsManager();
}

class Platform
{
    static class ThreadLocal :
        URIResolver,
        ResourceValidator,
        ResourceContentProvider
        //DocumentResourceAdaptor
    {
        static WorkflowRunner workflowRunner;

        Resource resolveURI(string uri,ResourceSet owner) {
            return null;
        }
        bool isValid(ResourceSet set) {
            return true;
        }
        bool isValidResource(Resource res) {
            return true;
        }
        void* getContent(Resource) {
            return null;
        }
        override ubyte[] getContent(Resource) {
            return [];
        }
        override void putContent(ubyte[],Resource) {
        }
        DocumentType getDocType(FileResource) {
            return null;
        }

        WorkflowRunner getWorkflowRunner() {
            if(workflowRunner is null) {
                workflowRunner = new WorkflowRunner;
            }
            return workflowRunner;
        }

    }
    static ThreadLocal _local;

    static auto getLocals() {
        if(_local is null) {
            _local = new ThreadLocal;
        }
        return _local;
    }

    static __gshared Platform INSTANCE;

    static auto getInstance() {
        static bool instantiated = false;
        if(!instantiated) {
            synchronized(Platform.classinfo) {
                if(!INSTANCE) {
                    INSTANCE=new Platform;
                }
            }
            instantiated = true;
        }
        return INSTANCE;
    }

    //static Workspace getDefaultWorkspace() {
    //    return resolveInjector!(Workspace)("app.workspace");
    //}
    static Workbench getDefaultWorkbench() {
        return resolveInjector!(Workbench)("app.workbench");
    }

    ExtensionsManager extensionsManager;

    private this() {
        extensionsManager = new ExtensionsManager;
    }

    _PluginLoader[string] plugins;

    class _PluginLoader : PluginLoader {
      override void load(string path) {
          super.load(path);
          plugins[desc.id] = this;
      }
    }
    PluginLoader newPluginLoader() {
      return new _PluginLoader();
    }
}

interface PlatformJob {
    T getProperty(T)(string id);
    void setProperty(T)(T t,string id);
}

abstract class PlatformJobBase : JobBase,PlatformJob {
    Workspace workspace;
    UCache cache;

    this(Workspace w = Platform.getInstance.getDefaultWorkbench.getWorkspace) {
        super();
        cache = UCache.CreateUCache();
        workspace = w;
    }

    //@property nothrow
    //ref inout (Variant[string]) param() inout {
    //    return _param;
    //}
    override void setup() {
        //Workspace.lock;
    }
    override void terminate() {
        //Workspace.unlock;
    }

    override void process() {
        processPlatformJob();
    }

    abstract void processPlatformJob();

    T getProperty(T)(string id) {
        return cache.put!T(id);
    }
    void setProperty(T)(T t,string id) {
        cache.put!T(id,t);
    }

}

struct PluginDef {
    public string name;
    public string pluginVersion;
    //public string[string] properties;
}

struct PlatformParam {
  PluginDef[] plugins;
}

alias DXXParam = Tuple!(
  PlatformParam,"dxx"
);

@component
class PlatformRuntime(Param...) :
            RuntimeComponents!(Param,PlatformParam),
            PlatformComponents {

    @component
    override URIResolver getURIResolver() {
        return Platform.getLocals();
    }

    @component
    override ResourceValidator getResourceValidator() {
        return Platform.getLocals;
    }

    @component
    override ResourceContentProvider getResourceContentProvider() {
        return Platform.getLocals;
    }

    //@component
    //override DocumentResourceAdaptor getDocumentResourceAdaptor() {
    //    return Platform.getInstance();
    //}

    @component
    override PluginLoader getPluginLoader() {
        return Platform.getInstance.newPluginLoader;
    }

    @component
    public ExtensionsManager getExtensionsManager() {
        return Platform.getInstance.extensionsManager;
    }

    @component
    public WorkflowRunner getWorkflowRunner() {
        return Platform.getLocals.getWorkflowRunner;
    }

    void registerPlatformDependencies(InjectionContainer injector) {
        Workspace w = new WorkspaceDefault;
        injector.register!(Workspace)(w,"app.workspace");
    }

    override void registerAppDependencies(InjectionContainer injector) {
        super.registerAppDependencies(injector);
        registerPlatformDependencies(injector);
    }
}
