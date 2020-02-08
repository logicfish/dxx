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
module dxx.app.devprops;

private import dxx.app.properties;

public import dxx.devconst;

version(DXX_Developer) {
  template CWD() {
    alias CWD=()=>runtimeConstants.curDir;
  }
  template APPDIR() {
    alias APPDIR=()=>runtimeConstants.appDir;
  }
  template ARCH() {
    alias ARCH=()=>Properties.__("build.arch");
  }
  template BUILD() {
    alias BUILD=()=>Properties.__("build.buildType");
  }
  template DEBUGS() {
    alias DEBUGS=()=>Properties.___("build.debugs");
  }
  template VERSIONS() {
    alias VERSIONS=()=>Properties.___("build.versions");
  }
  template CONFIG() {
    alias CONFIG=()=>Properties.__("build.config");
  }
  template FORCE() {
    alias FORCE=()=>Properties._!bool("build.force");
  }
  template NODEPS() {
    alias NODEPS=()=>Properties._!bool("build.nodeps");
  }
  template PARALLEL() {
    alias PARALLEL=()=>Properties._!bool("build.parallel");
  }
  string[] buildDubArgs(string cmd)(string root=".") {
    import std.conv : to;
    string[] args;
    args ~= [
      cmd,
      "--arch="~ARCH,
      "--build="~BUILD,
      //"--config="~CONFIG,
      "--force="~FORCE.to!string,
      "--root="~root,
      "--nodeps="~NODEPS.to!string,
      "--parallel="~PARALLEL.to!string
    ];
    foreach(dbg;DEBUGS) {
        args ~= [ "--debug="~dbg ];
    }
    foreach(vers;VERSIONS) {
        args ~= [ "--version="~vers ];
    }
    return args;
  }
}
