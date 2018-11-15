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

interface DocumentResourceAdaptor {
    DocumentType getDocType(FileResource);
}

interface PlatformComponents {
    URIResolver getURIResolver();
    ResourceValidator getResourceValidator();
    ResourceContentProvider getResourceContentProvider();
    DocumentResourceAdaptor getDocumentResourceAdaptor();
}

@component
class PlatformRuntime(Param...) 
            : RuntimeComponents!(Param), PlatformComponents {
    @component
    URIResolver getURIResolver() {
        return Platform.getInstance;
    }
    
    @component
    ResourceValidator getResourceValidator() {
        return Platform.getInstance;
    }
    
    @component
    ResourceContentProvider getResourceContentProvider() {
        return Platform.getInstance;
    }
    
    @component
    DocumentResourceAdaptor getDocumentResourceAdaptor() {
        return Platform.getInstance;
    }
    void registerPlatformDependencies(InjectionContainer injector) {
        injector.register!(Workspace)(new WorkspaceDefault,"app.workspace");
    }
    override void registerAppDependencies(InjectionContainer injector) {
        injector.registerPlatformDependencies;
    }
}

class Platform  
        : URIResolver, ResourceValidator,ResourceContentProvider,DocumentResourceAdaptor 
{
    static __gshared Platform INSTANCE;
    static bool instantiated = false;

    //shared static this() {
    //    assert(INSTANCE is null);
    //    INSTANCE=new Platform;
    //}
    
    static auto getInstance() {
        if(!instantiated) {
            synchronized(Platform.classinfo) {
                if(!INSTANCE) {
                    INSTANCE=new Platform;
                }
            }
            instantiated = true;
        }
    }

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
    DocumentType getDocType(FileResource) {
        return null;
    }

    static Workspace getDefaultWorkspace() {
        return resolveInjector!(Workspace)("app.workspace");
    }

}


