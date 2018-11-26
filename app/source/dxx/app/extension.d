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
module dxx.app.extension;

private import std.algorithm;

private import hunt.cache;

private import dxx.util;

struct ExtensionPointDesc {
    string id;
    string symbolicName;
    string description;
    string url;
    void* executableExtension;
}

interface ExtensionPoint {
    //const(string) id();
    inout(ExtensionPointDesc) desc() inout;
}

struct ExtensionDesc {
    string id;
    string symbolicName;
    string extensionPoint;
    string description;
    string url;
    //void* delegate(string id) createExecutableExtension;
    ConfigurationElement[string] configuration;
    //void*  createExecutableExtension(string id){
    //    return null;
    //}
}

struct ConfigurationElement {
    string id;
    string[string] attr;
    ConfigurationElement[] children;
    //ExtensionDesc* extension;
    //ConfigurationElement* parent;
}

interface Extension {
    inout(ExtensionDesc) desc() inout;
}

struct ExtensionEvent {
    enum Type {
        Register,Unregister
    };
    @property
    Type eventType;
    @property
    string pluginId;
    @property
    ExtensionDesc* extension;
}

class ExtensionsManager : SyncNotificationSource {
    static class _Event {
      ExtensionEvent ev;
      this(ExtensionEvent.Type evType,string pluginId,ExtensionDesc* x) {
        ev=ExtensionEvent(evType,pluginId,x);
      }
    };

    UCache xpCache;
    UCache xCache;
    void enumerateExtensions(alias T)(string xp) {
        //extensions.filter!(a => a.desc.extensionPoint == xp).each!(a => T(a));
    }
    void enumerateExtensionPoints(alias T)(string xp) {
    }
    this() {
        xpCache = UCache.CreateUCache();
        xCache = UCache.CreateUCache();
    }
    void sendExtensionEvent(ExtensionEvent.Type type,string pluginId,ExtensionDesc* x) {
      auto e = new _Event(type,pluginId,x);
      _send!ExtensionEvent(&e.ev);
    }
    void registerExtensionPoint(ExtensionPointDesc* xp,string pluginId) {
        //xpCache.put(pluginId ~ "." ~ xp.id,xp);
    }
    void unregisterExtensionPoint(ExtensionPointDesc* xp,string pluginId) {
        //xpCache.remove(pluginId ~ "." ~ xp.id);
    }
    void registerExtension(ExtensionDesc* x,string pluginId) {
        //xCache.put(pluginId ~ "." ~ x.id,x);
        sendExtensionEvent(ExtensionEvent.Type.Register,pluginId,x);
    }
    void unregisterExtension(ExtensionDesc* x,string pluginId) {
        //xCache.remove(pluginId ~ "." ~ x.id);
        sendExtensionEvent(ExtensionEvent.Type.Unregister,pluginId,x);
    }
}
