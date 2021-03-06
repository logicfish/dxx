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
module dxx.app.platform;

private import std.exception;
private import std.typecons;
private import std.variant;

private import aermicioi.aedi;

//import hunt.cache;

private import dxx.util;
private import dxx.app;

private import dxx.app.component;
private import dxx.app.resource;
private import dxx.app.document;
private import dxx.app.workbench;
private import dxx.app.extension;
private import dxx.app.resource.impl.wsmanager;


//interface DocumentResourceAdaptor {
    //DocumentType getDocType(FileResource);
//}

/++
Methods exposed by the platform, accessible via the injector.
++/
interface PlatformComponents {
    URIResolver getURIResolver();
    ResourceValidator getResourceValidator();
    ResourceContentProvider getResourceContentProvider();
    //DocumentResourceAdaptor getDocumentResourceAdaptor();

    public WorkflowRunner getWorkflowRunner();
    public PluginLoader getPluginLoader();
    public ExtensionsManager getExtensionsManager();
    //public Cache getLocalCache();
}

struct PlatformJobEvent {
  enum Status {
    Setup,Process,Terminate
  };
  Status status;
  shared(PlatformJob) job;
}
/++
This represents the state of the framework for an application.
The platform handles the resource workspace, loading of plugins and is
also a job manager.
++/
class DXXPlatform : SyncNotificationSource
{
    static class ThreadLocal :
        URIResolver,
        ResourceValidator,
        ResourceContentProvider
        //DocumentResourceAdaptor
    {
        static WorkflowRunner workflowRunner;
        //Cache localCache;

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
        /*Cache getLocalCache() {
          if(localCache is null) {
            localCache =  CacheFectory.create();
          }
          return localCache;
        }*/
    }
    static ThreadLocal _local;

    static auto getLocals() {
        if(_local is null) {
            _local = new ThreadLocal;
        }
        return _local;
    }

    static __gshared DXXPlatform INSTANCE;

    static
    auto getInstance() {
        static bool instantiated = false;
        if(!instantiated) {
            synchronized(DXXPlatform.classinfo) {
                if(!INSTANCE) {
                    INSTANCE=new DXXPlatform;
                }
            }
            instantiated = true;
        }
        return INSTANCE;
    }

    static Workspace getDefaultWorkspace() {
        return resolveInjector!(Workspace)("app.workspace");
    }
    /* static Workbench getDefaultWorkbench() {
        return resolveInjector!(Workbench)("app.workbench");
    } */

    ExtensionsManager extensionsManager;

    private this() {
        extensionsManager = new _ExtensionsManager;
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

    static nothrow
    void sendJobEvent(
        PlatformJobEvent.Status status)
        (shared(PlatformJob) j)
    {
        try {
          PlatformJobEvent event = PlatformJobEvent(status,j);
          auto p = cast(shared(DXXPlatform))getInstance;
          p.send!PlatformJobEvent(&event);
        } catch(Exception e) {
          MsgLog.warning(e.message);
        }
    }
    static void executeJob(shared(Job) job) {
      //auto j = cast(shared(Job))job;
      job.execute;
    }

    static void clearLocalCache() {
      //destroy(getLocals.localCache);
    }
}

/++
Job that sends events to the DXXPlatform listeners.
++/
interface PlatformJob : Job {
    T getProperty(T)(string id);
    void setProperty(T)(T t,string id);
}

abstract class PlatformJobBase : JobBase,PlatformJob {
    shared(Workbench) workbench;
    Variant[string] _props;

     this(Workbench w = resolveInjector!(Workbench)("app.workbench")) shared {
        //super();
        workbench = cast(shared(Workbench))w;
    }
    this() shared {
        //super();
    }

    override
    void setup() shared {
      DXXPlatform.sendJobEvent!(PlatformJobEvent.Status.Setup)(this);
    }
    override
    void terminate() shared {
      DXXPlatform.sendJobEvent!(PlatformJobEvent.Status.Terminate)(this);
    }

    override
    void process() shared {
        DXXPlatform.sendJobEvent!(PlatformJobEvent.Status.Process)(this);
        processPlatformJob();
    }

    abstract
    void processPlatformJob() shared;

    //override
    T getProperty(T)(string id) {
        return _props[id].get!T;
    }
    //override
    void setProperty(T)(T t,string id) {
      _props[id] = Variant(t);
    }
}

struct PluginDef {
    public string name;
    public string pluginVersion;
    public string path;
    //public string[string] properties;
}

struct PlatformParam {
  PluginDef[] plugins;
}

alias DXXParam = Tuple!(
  PlatformParam,"dxx"
);

/++
Default runtime module that exposes components for use by the injector.


So, for example, to access a PluginLoader:
`
    PluginLoader loader = resolveInjector!PluginLoader;
`
++/
@component
class PlatformRuntime(Param...) :
            RuntimeComponents!(Param,PlatformParam),
            PlatformComponents {

    @component
    override URIResolver getURIResolver() {
        return DXXPlatform.getLocals();
    }

    @component
    override ResourceValidator getResourceValidator() {
        return DXXPlatform.getLocals;
    }

    @component
    override ResourceContentProvider getResourceContentProvider() {
        return DXXPlatform.getLocals;
    }

    //@component
    //override DocumentResourceAdaptor getDocumentResourceAdaptor() {
    //    return Platform.getInstance();
    //}

    @component
    override PluginLoader getPluginLoader() {
        return DXXPlatform.getInstance.newPluginLoader;
    }

    @component
    public ExtensionsManager getExtensionsManager() {
        return DXXPlatform.getInstance.extensionsManager;
    }

    @component
    public WorkflowRunner getWorkflowRunner() {
        return DXXPlatform.getLocals.getWorkflowRunner;
    }
    /*@component
    override Cache getLocalCache() {
        return DXXPlatform.getLocals.getLocalCache;
    }*/

    void registerPlatformDependencies(InjectionContainer injector) {
      WorkspaceManager w = new WorkspaceManager;
      Workspace ws = w.workspace;
      injector.register!(Workspace)(ws,"app.workspace");
    }

    override void registerAppDependencies(InjectionContainer injector) {
        super.registerAppDependencies(injector);
        registerPlatformDependencies(injector);
    }
    version(unittest) {
        alias UTParam = Tuple!(
           string,"name",
           uing,"age"
          );
        mixin registerComponent!(PlatformRuntime!UTParam);
    }
}
unittest {
  WorkflowRunner runner = resolveInjector!WorkflowRunner;
  assert(runner !is null);
  PluginLoader loader = resolveInjector!PluginLoader;
  assert(loader !is null);
}
