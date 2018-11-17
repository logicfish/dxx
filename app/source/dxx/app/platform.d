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

private import aermicioi.aedi;

private import dxx.util;

private import dxx.app.resource;
private import dxx.app.document;
private import dxx.app.component;

//interface DocumentResourceAdaptor {
    //DocumentType getDocType(FileResource);
//}

interface PlatformComponents {
    URIResolver getURIResolver();
    ResourceValidator getResourceValidator();
    ResourceContentProvider getResourceContentProvider();
    //DocumentResourceAdaptor getDocumentResourceAdaptor();
}

class Platform  
{
    static class ThreadLocal :
        URIResolver, 
        ResourceValidator,
        ResourceContentProvider
        //DocumentResourceAdaptor 
    {
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
    }
    static ThreadLocal _local;
    static auto getLocals() {
        if(_local is null) {
            _local = new ThreadLocal;
        }
        return _local;
    }
        
    static __gshared Platform INSTANCE;
    static bool instantiated = false;
    
    static auto getInstance() {
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

    static Workspace getDefaultWorkspace() {
        return resolveInjector!(Workspace)("app.workspace");
    }

}

@component
class PlatformRuntime(Param...) 
            : RuntimeComponents!(Param), PlatformComponents {
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
    
    void registerPlatformDependencies(InjectionContainer injector) {
        Workspace w = new WorkspaceDefault;
        injector.register!(Workspace)(w,"app.workspace");
    }
    
    override void registerAppDependencies(InjectionContainer injector) {
        super.registerAppDependencies(injector);
        registerPlatformDependencies(injector);
    }
}


