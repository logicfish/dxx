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
module dxx.app.resource.workspace;

private import aermicioi.aedi;

private import dxx.app.resource;
private import dxx.app.document;

interface Workspace {
    enum ResourceLocation {
        CONFIG,SYSTEM,PROJECT
    };
    Project getProject(string name);
    Project[] getProjects();
    Resource getResource(string uri,ResourceSet owner);
    string getNativePath(string uri);
    string getNativePath(Project);
}

class WorkspaceDefault : Workspace {
    @autowired
    URIResolver uriResolver;
    
    @autowired
    ResourceValidator validator;

    Project[string] projects;
    
    override Resource getResource(string uri,ResourceSet owner) {
        return uriResolver.resolveURI(uri,owner);
    }
    
    string getNativePath(string uri) {
        return uri;
    }
    string getNativePath(Project p) {
        return getNativePath(p.uri);
    }
    Project getProject(string name) {
        return null;
    }
    Project[] getProjects() {
        return null;
    }
}

