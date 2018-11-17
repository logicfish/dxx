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
module dxx.app.resource.resource;

interface URIResolver {
    /++
    Resolve a URI in space or in the filesystem.
    ++/
    Resource resolveURI(string uri,ResourceSet owner);
}

interface ResourceValidator {
   bool isValid(ResourceSet set);
   bool isValidResource(Resource res);
}

interface ResourceContentProvider {
    ubyte[] getContent(Resource);
    void putContent(ubyte[],Resource);
}

struct ResourceMetaData {
    string ns;
    string content;
}

interface ResouceMetaDataProvider {
    ResourceMetaData[] getMetaData(string id,string uri);
    void setMetaData(ResourceMetaData[] data,string id,string uri);
}

interface Resource {
    ResourceSet owner();
    Resource parent();
    Resource[] children();
    const(string) uri();
    bool isFolder();
    //byte[] contents();
    //int putContents(byte[]);
}

interface FileResource : Resource {
}

interface FolderResource : FileResource {
}

final class ResourceSet {
    Resource[const(string)] uriMap;

    auto getResouce(const(string) uri) {
        return uriMap[uri];
    }

    auto importResource(Resource r) {
        if (r.uri in uriMap) return null;
        uriMap[r.uri] = r;
        return r;
    }

    Resource[] getAll() {
        return uriMap.values;
    }
}


