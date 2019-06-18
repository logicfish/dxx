/**
Copyright 2019 Mark Fisher

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
module dxx.devconst;

public import dxx.constants;

version(DXX_Bootstrap) {
  private import aermicioi.aedi;
  private import aermicioi.aedi_property_reader;

  static Container __c;

  template _(T) {
    auto _(string v) {
      return __c.locate!T(v);
    }
  }

  auto __(string v) {
    return _!string(v);
  }
  auto ___(string v) {
    return _!(string[])(v);
  }

  template CWD() {
    alias CWD=()=>RTConstants.curDir;
  }
  template APPDIR() {
    alias APPDIR=()=>RTConstants.appDir;
  }
  template APPS() {
    alias APPS=()=>___("build.apps");
  }

  template PROJECTS() {
    alias PROJECTS=()=>___("build.projects");
  }

  template UTPROJECTS() {
    alias UTPROJECTS=()=>___("ut.projects");
  }
  template ARCH() {
    alias ARCH=()=>__("build.arch");
  }
  template BUILD() {
    alias BUILD=()=>__("build.build");
  }
  template DEBUGS() {
    alias DEBUGS=()=>___("build.debugs");
  }
  template VERSIONS() {
    alias VERSIONS=()=>___("build.versions");
  }

  template FORCE() {
    alias FORCE=()=>__("build.force");
  }

  template NODEPS() {
    alias NODEPS=()=>__("build.nodeps");
  }

  template EXEPATH() {
    alias EXEPATH = runtimeConstants.appFileName;
  }
  template EXEDIR() {
    alias EXEDIR = runtimeConstants.appDir;
  }

  void load(T : DocumentContainer!X, X...)(T container) {
  	with (container.configure) { // Create a configuration context for config container
  		register!string("build.arch"); // Define `protocol` property of type `string`
  		register!string("build.build");

      register!(string[])("build.debugs");
      register!(string[])("build.versions");
      register!(string)("build.config");
      register!(string[])("build.projects");
      register!(string[])("build.apps");
      register!(string)("build.tag");
      register!(string)("build.force");
      register!(string)("build.nodeps");

      register!string("ut.arch"); // Define `protocol` property of type `string`
  		register!string("ut.build");
      register!(string[])("ut.debugs");
      register!(string[])("ut.versions");
      register!(string)("ut.config");
      register!(string[])("ut.projects");
  	}
  }

  static this() {
    auto c = container(
      //singleton,
      //prototype,
      argument,
      env,
      //xml("config.xml"),
      json("resources/dale.json"),
      json("resources/dale-default.json"),
      //yaml("config.yaml"),
      //sdlang("config.sdlang")
    );

	  foreach (subcontainer; c) {
		    subcontainer.load;
    }
    __c = c;

  }

  string[] buildDubArgs(string cmd)(string root=".") {
    string[] args;
    args ~= [
      cmd,
      "--root="~root
    ];
    static if ("build" == cmd || "run" == cmd || "test" == cmd) {
      args ~= [
        "--arch="~ARCH,
        "--build="~BUILD,
        //"--config="~CONFIG,
        "--force="~FORCE,
        "--nodeps="~NODEPS
      ];
      foreach(dbg;DEBUGS) {
          args ~= [ "--debug="~dbg ];
      }
      foreach(vers;VERSIONS) {
          args ~= [ "--version="~vers ];
      }
    }
    return args;
  }
}
