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
module dxx.app.resource.file;

public import dxx.util;
public import dxx.app;

struct FileResourceDesc {
    string uri;
    bool isFolder;
    void* contents;
}

abstract class ResourceBase : SyncNotificationSource, Resource {

}

abstract class FileOrFolderResourceBase : ResourceBase, Resource {
    string _uri;
    FolderResource _parent;
    Project _parentProject;
    Resource[] _children;
    //void* _contents;
    Workspace _parentWorkspace;

    Project parentProject() {
      return _parentProject;
    }

    ResourceSet owner() {
        return owner;
    }

    @property
    override Resource parent() {
        return _parent;
    }

    @property
    override Resource[] children() {
        return _children;
    }

    @property
    override const(string) uri() {
        return _uri;
    }

    this(string uri,FolderResource parent) {
      this._uri = uri;
      this._parent = parent;
      if(parent !is null) {
        this._parentWorkspace = parent.parentWorkspace;
      } else {
        this._parentWorkspace = DXXPlatform.getDefaultWorkspace;
      }
    }

    Workspace parentWorkspace() {
      return _parentWorkspace;
    }
}

class FileResourceBase : FileOrFolderResourceBase,FileResource {
    this(string uri,FolderResource parent) {
        super(uri,parent);
    }
    override bool isFolder() {
        return false;
    }
    //override void* contents() {
    //    return null;
    //}
    //@property
    //override void* contents() {
    //    return _contents;
    //}

}

class FolderResourceBase : FileOrFolderResourceBase,FolderResource {
    this(string uri,FolderResource parent) {
        super(uri,parent);
    }
    override bool isFolder() {
        return true;
    }
}
