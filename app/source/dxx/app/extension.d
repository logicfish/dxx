/*
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
*/
module dxx.app.extension;

private import std.algorithm;
private import std.variant;
import std.typecons : Proxy;

private import hunt.cache;
private import witchcraft;

private import dxx.util;
private import dxx.app.plugin;

struct ExtensionPointDesc {
    string id;
    string symbolicName;
    string description;
    string url;
    //void*[string] executableExtensions;
    ConfigurationElement[string] configuration;
}

interface ExtensionPoint {
    //const(string) id();
    inout(ExtensionPointDesc) desc() inout;
}

struct ConfigurationElement {
    enum ElementType {
      STRING_VAL,
      INT_VAL,
      FLOAT_VAL,
      ARRAY_VAL,
      // the xp parameter is an instance of a given type
      // hosted by the plugin exposing the extension point.
      TYPE_VAL,
      // the xp parameter represents a static method in the exposing plugin.
      METHOD_VAL
    }
    @property
    ElementType elementType;
    @property
    string id;
    @property
    Variant[string] attr;
    @property
    ConfigurationElement[] children;
    @property
    ConfigurationElement* parent;
    @property
    ExtensionPointDesc* extensionPoint;
}

struct ExtensionDesc {
    string id;
    string symbolicName;
    string extensionPoint;
    string description;
    string url;
    //void* delegate(string id) createExecutableExtension;
    //ConfigurationElement[string] configuration;
    //void*  createExecutableExtension(string id){
    //    return null;
    //}
    //void*[string] executableExtensions;
    ConfigurationSetting[] settings;
}

struct ConfigurationSetting {
  ExtensionDesc* extension;
  ConfigurationElement* element;
  Variant value;
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

interface ExecutableExtensionType {
  string executableType();
  //Variant executable();
  //Variant methods();
  Method[] methods();
  Variant create();
}

interface ExecutableExtension {
  ExecutableExtensionType executableType();
  Variant object();
}

mixin template exportExecutableExtension(T) {
  void exportExecutableExtension(string id,string pluginId) {
      // register the export with the injector
  }
}

mixin template importExecutableExtension(alias T) {
  void importExecutableExtension(string id,string pluginId) {
      // register the import with the injector
  }
}

interface ExtensionsManager : NotificationSource {
  void registerExtensionPoint(ExtensionPointDesc* xp,string pluginId);
  void registerExecutableExtensionType(ExtensionPointDesc* xp,string pluginId,string id,ConfigurationElement elem);
  ExecutableExtensionType findExecutableExtensionType(string type,string pluginId);
  Variant createExecutableExtension(string stype,string pluginId,string id);
  void unregisterExtensionPoint(ExtensionPointDesc* xp,string pluginId);
  void registerExtension(ExtensionDesc* x,string pluginId);
  void unregisterExtension(ExtensionDesc* x,string pluginId);
}

final class _ExtensionsManager : SyncNotificationSource,ExtensionsManager {
    static class _Event {
      ExtensionEvent ev;
      this(ExtensionEvent.Type evType,string pluginId,ExtensionDesc* x) {
        ev=ExtensionEvent(evType,pluginId,x);
      }
    };
    class _ExecutableExtension(T) : T,ExecutableExtension {
      T ext;
      mixin Witchcraft;

      string executableType() {
        return typeid(T);
      }
      void* executable() {
        return &this;
      }
      this(T* t,string pluginId) {
        ext=t;
//        executableExtensionTypes[pluginId][typeid(T)] = this;
      }
    }
    class _ExecutableExtensionType(T) : ExecutableExtensionType {
      string executableType() {
        return typeid(T);
      }
      this(string pluginId) {
        executableExtensionTypes[pluginId][typeid(T)] = this;
      }
    }
    ExecutableExtensionType[string][string] executableExtensionTypes;
    Cache xpCache;
    Cache xCache;

    void enumerateExtensions(alias T)(string xp) {
        //extensions.filter!(a => a.desc.extensionPoint == xp).each!(a => T(a));
    }
    void enumerateExtensionPoints(alias T)(string xp) {
    }
    this() {
        xpCache = CacheFactory.create();
        xCache = CacheFactory.create();
    }
    void sendExtensionEvent(ExtensionEvent.Type type,string pluginId,ExtensionDesc* x) {
      auto e = new _Event(type,pluginId,x);
      //_send!ExtensionEvent(&e.ev);
      throw new Exception("NYI");
    }
    //
    void registerExtensionPoint(ExtensionPointDesc* xp,string pluginId) {
        //xpCache.put(pluginId ~ "." ~ xp.id,xp);
        foreach(k,v;xp.configuration) {
          switch(v.elementType) {
            case ConfigurationElement.ElementType.TYPE_VAL:
              registerExecutableExtensionType(xp,pluginId,k,v);
            break;
            default:
            break;
          }
        }
    }
    void registerExecutableExtensionType(ExtensionPointDesc* xp,string pluginId,string id,ConfigurationElement elem) {
        auto elemType = elem.attr["type"];

    }
    ExecutableExtensionType findExecutableExtensionType(string type,string pluginId) {
      return null;
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
    Variant createExecutableExtension(string type,string pluginId,string id) {
      auto n = pluginId in executableExtensionTypes;
      if(n) {
        auto m = type in executableExtensionTypes[pluginId];
        if(m) {
          return createLocalExexcutable(id,executableExtensionTypes[pluginId][type]);
        }
      }
      return Variant(null);
    }
    Variant createLocalExexcutable(string id,ExecutableExtensionType extType) {
      //executableType
      return Variant(null);
    }

    version(DXX_Plugin) {
      // The plugin version of the manager is just a stub that reflects to
      // the host. However it exposes the notification interface to the plugin
      // and registration events are sent only to the container plugin.
      // The host receiver gets a notification signal on all registration events.
      auto getPlugin() {
        return PluginDefault.getInstance;
      }
    } else {

    }

}
