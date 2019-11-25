/**
Copyright: 2019 Mark Fisher

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
module dxx.util.service;

private import std.range;


struct ServiceReference {
  string[] typeId;
  string pluginId;
  void* _handle;
  string[string] _properties;

  @property nothrow
  inout auto ref
  properties() shared {
    return _properties;
  }
  @property nothrow
  inout auto ref
  properties() {
    return _properties;
  }
  @property nothrow
  auto ref
  properties(string[string] p) {
    _properties = p;
    return _properties;
  }

  @safe
  bool matches(string[string] m) shared {
    if(m is null || m.empty) {
      return true;
    }
    foreach(k,v; m) {
      if(k !in _properties) return false;
      if(v != "*" && v != _properties[k]) return false;
    }
    return true;
  }
};

struct ServiceRegistration {
  ServiceReference reference;
  alias reference this;

  void* service;
  void* _regHandle;
};


struct ServiceNotification {
  enum Type {
    Registered,
    Unregistered,
    Modified
  }
  Type notificationType;
  const(ServiceReference) reference;
  string[string] props;
};

alias ServiceEventListener = void delegate(ServiceNotification);

abstract class ServiceNotificationHandler {
  void handleServiceNotification(ServiceNotification n) @safe nothrow;
}
