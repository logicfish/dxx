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
module dxx.app.resource.project;

import dxx.app.resource.file;

interface ProjectType {
  @property pure @safe @nogc nothrow
  inout(string) typeName() inout;
  abstract string[] buildCommand();
  abstract string[] execCommand();
}

abstract class ProjectTypeBase : ProjectType {
  string _typeName;
  @property pure @safe @nogc nothrow override
  inout(string) typeName() inout {
    return _typeName;
  }
  string[] buildCommand() {
    return [];
  }
  string[] execCommand() {
    return [];
  }
}

class DefaultProjectType : ProjectTypeBase {

}

class ProjectBase : FolderResourceBase,Project {
  ProjectDesc _desc;
  ProjectType _type;

  @property pure @safe @nogc nothrow
  inout(ProjectDesc) desc() inout {
    return _desc;
  }

  @property pure @safe @nogc nothrow
  inout(ProjectType) type() inout {
    return _type;
  }

  this(string uri,FolderResource parent,ProjectType _type = new DefaultProjectType) {
      super(uri,parent);
      this._type = _type;
  }

}
