/**
Static methods to lookup application properties at
runtime. Firstly, the methods queries the LocalConfig.
If the key is not found, then the method consults the
local injector. If the key is still not found, then a
static variant map comprising default values is consulted.
If the key is still not found, the methods return null.

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
        return null;
    }

    nothrow
    static T lookup(T,k : string)() {
      return lookup!T(k);
    }

    nothrow
    static string lookupString(string k) {
      return lookup!string(k);
    }
    static string expand(string v)() {
      return miniTemplate!(lookupString)(v);
    }
}

unittest {
  auto n = Properties.lookup!string(DXXConfig.keys.appName);
  assert(n ==  RTConstants.constants.appBaseName);
}

unittest {
  auto n = Properties.expand("{{"~DXXConfig.keys.appName~"}}");
  assert(n ==  RTConstants.constants.appBaseName);
}
