/**
Static methods to lookup application properties at
runtime. Firstly, the methods queries the LocalConfig.
If the key is not found, then the method consults the
local injector. If the key is still not found, then a
static variant map comprising default values is consulted.
If the key is still not found, the methods return null.

The lookup methods are nothrow.

The __gshared property_defaults array is not synchronized and
should be initialised once by the application.

The expand method takes a string and replaces
occurences of "{{fullyQualifiedIdentifier}}"
with the value obtained by looking up the id.

Copyright: Copyright 2018 Mark Fisher

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
module dxx.app.properties;

private import std.variant;
private import std.algorithm;

private import dxx.util;

class Properties {
    __gshared static Variant[string] property_defaults;

    nothrow
    static T lookup(T)(string k) {
        try {
          auto v = LocalConfig.get(k);
          if(v != null) return v.get!T;
        } catch(Exception e) {
        }
        try {
          return getInjectorProperty!T(k);
        } catch(Exception e) {
          if(k in property_defaults) {
            try {
              return property_defaults[k].get!T;
            } catch(Exception e) {
            }
          }
        }
        static if(typeid(T) is typeid(bool)) {
          return false;
        } else {
          return null;
        }
    }

    nothrow
    static T lookup(T,k : string)() {
      return lookup!T(k);
    }

    nothrow
    static auto resolve(T)() {
        try {
          return resolveInjector!T;
        } catch(Exception e) {
        }
        return null;
    }

    nothrow static
    auto idParser(string k) {
      return lookup!string(k);
    }
    nothrow static
    auto expand(string v) {
      //return miniInterpreter!(idParser)(v);
      return v;
    }
    /*template expand(alias F) {
      nothrow static
      auto lookupStringF(k : string)() {
        auto n = lookup!(string,k);
        if(n is null) return F(k);
        else return n;
      }
      auto expand(string v) {
        return miniTemplate!(lookupStringF,v);
      }
    }*/
    /*static string opDispatch(string s)() {
        return lookupString(s);
    }*/
    static T opIndex(T)(string s) {
      return _!T(s);
    }
    // helpers
    static auto _(T)(string v) {
      return Properties.lookup!T(v);
    }

    static auto __(string v) {
      return expand(_!string(v));
    }
    static auto ___(string v) {
      return _!(string[])(v).map!(x=>expand(x));
    }

}

unittest {
  import dxx;
  auto n = Properties.lookup!string(DXXConfig.keys.appName);
  assert(n ==  RTConstants.constants.appBaseName);
}

unittest {
  import dxx;
  auto n = Properties.expand("{{"~DXXConfig.keys.appName~"}}");
  assert(n ==  RTConstants.constants.appBaseName);
}

unittest {
  import dxx;
  auto n = Properties.expand("XX{{"~DXXConfig.keys.appName~"}}XX");
  assert(n ==  "XX"~RTConstants.constants.appBaseName~"XX");
}

unittest {
  import dxx;
  auto n = Properties.expand("XX{{"~DXXConfig.keys.appName~"}}XX{{"~DXXConfig.keys.appName~"}}XX");
  assert(n ==  "XX"~RTConstants.constants.appBaseName~"XX"~RTConstants.constants.appBaseName~"XX");
}

unittest {
  import dxx;
  auto n = Properties.__(DXXConfig.keys.appName);
  assert(n ==  RTConstants.constants.appBaseName);
}
