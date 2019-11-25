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

private import std.json;

public import dxx.constants;

version(DXX_Bootstrap) {
  //private import aermicioi.aedi;
  private import std.variant;
  //static Container __c;
  static Variant[string] __p;

  template _(T) {
    auto _(string v) {
      //return __c.locate!T(v);
      if(auto x = v in __p) {
        return x.get!T;
      }
      return null;
    }
  }

  auto __(string v) {
    return _!string(v);
  }
  auto ___(string v) {
    return _!(string[])(v);
  }

  template CWD() {
    alias CWD=()=>runtimeConstants.curDir;
  }
  template APPDIR() {
    alias APPDIR=()=>runtimeConstants.appDir;
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
    alias EXEPATH =()=>runtimeConstants.appFileName;
  }
  template EXEDIR() {
    alias EXEDIR = ()=>runtimeConstants.appDir;
  }
  template APPARG() {
    alias APPARG = ()=>runtimeConstants.argsApp;
  }
  template ARGPASS() {
    alias ARGPASS = ()=>cast(string[])runtimeConstants.argsAppPassthrough.dup;
  }

  string[] toStringArray(const(JSONValue)[] ar) {
    string[] res;
    foreach(v;ar) {
      res ~= v.str;
    }
    return res;
  }
  //void load(T : DocumentContainer!X, X...)(T container) {
  //void load(T)(T container) {
  void load(const(JSONValue) __j) {
  	//with (container.configure) { // Create a configuration context for config container
    import std.string : indexOf;

    void _register(_T)(string name,string fqn="",const(JSONValue) j=__j) {
        debug {
          import std.experimental.logger;
          debug(DXX_Developer) {
            sharedLog.trace("reg ",fqn," ",name);
          }
        }
        auto inx = name.indexOf('.');
        if(inx != -1) {
          string n = name[0..inx];
          if(const(JSONValue)* x = n in j) {
            _register!_T(name[inx+1..$],n ~ ".",*x);
            return;
          }
        }
        if(const (JSONValue)* val = name in j) {
          name = fqn ~ name;
          static if(is(_T == int)) {
            //register!_T(val.integer,name);
            __p[name] = Variant(val.integer);
          } else if(is(_T == bool)) {
            //register!_T(val.boolean,name);
            __p[name] = Variant(val.boolean);
          } else if (is(_T == string)) {
            //register!_T(val.str,name);
            __p[name] = Variant(val.str);
          } else if (is(_T == string[])) {
            string[] vals;
            vals = toStringArray(val.array);
            //register!(string[])(vals,name);
            __p[name] = Variant(vals);
          }
        } else {
          static if(is(_T == int)) {
            __p[name] = Variant(-1);
          } else if(is(_T == bool)) {
            __p[name] = Variant(false);
          } else if (is(_T == string)) {
            __p[name] = Variant("");
          } else if (is(_T == string[])) {
              string[] x = [];
            __p[name] = Variant(x);
          }
        }
    }
    //with(__j) {
  		_register!string("build.arch"); // Define `protocol` property of type `string`
  		_register!string("build.build");

      _register!(string[])("build.debugs");
      _register!(string[])("build.versions");
      _register!(string)("build.config");
      _register!(string[])("build.projects");
      _register!(string[])("build.apps");
      _register!(string)("build.tag");
      _register!(string)("build.force");
      _register!(string)("build.nodeps");

      _register!string("ut.arch"); // Define `protocol` property of type `string`
  		_register!string("ut.build");
      _register!(string[])("ut.debugs");
      _register!(string[])("ut.versions");
      _register!(string)("ut.config");
      _register!(string[])("ut.projects");
  	//}
  }

  auto loadJson(string pathOrData) {
    import std.file : exists, readText;
    if (pathOrData.exists) {
      debug(trace) trace("Loading json from ", pathOrData);
      pathOrData = pathOrData.readText();
    }
    return parseJSON(pathOrData);
  }

  static this() {
    /* auto c = container(
      //singleton,
      //prototype,
      argument,
      env,
      //xml("config.xml"),
      json("resources/dale.json"),
      json("resources/dale-default.json"),
      //yaml("config.yaml"),
      //sdlang("config.sdlang")
    ); */
    import std.file : exists, readText;
    auto __j = loadJson("resources/dale.json");

    load(__j);

    /*auto c = container(prototype);

	  foreach (subcontainer; c) {
		    subcontainer.load;
    }
    __c = c;*/

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
