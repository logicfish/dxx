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
module dxx.app.services;

private import std.exception;
private import std.algorithm;
private import std.range;
private import std.conv;

private import dxx.app.cache;

private import dxx.util;
private import dxx.app;

public import dxx.util.service;

class Registration {
  ServiceRegistration reg;
  alias reg this;

  class Ref {
    ServiceReference reference;
    alias reference this;

    int count;
    this(string _pluginId) shared {
      count = 0;
      reference.pluginId = _pluginId;
      reference._handle = cast(shared(void*))this;
      typeId = reg.typeId;
      properties = reg.properties;
    }
    void release() shared {
      count = count - 1;
      if(count == 0) {
        //references.remove(reference.pluginId);
      }
    }
    auto addRef() shared {
      count = count + 1;
      if(count == 1) {
        //references[pluginId] = this;
      }
      return this;
    }
    /* string fullyQualifiedIdentifier() shared {
      return this.outer.fullyQualifiedIdentifier;
    } */
    auto service() shared {
      return this.outer.service;
    }
  }

  //Ref[string] references;

  shared(Ref) createRef(string _pluginId) shared {
    //auto a = require(cast(shared(Ref)[string])references,_pluginId,new shared(Ref)(_pluginId));
    /* if(_pluginId !in references) {
      auto a = new shared(Ref)(_pluginId);
      return a.addRef;
    }
    return references[pluginId].addRef; */
    return null;
  }
  void releaseRef(string _pluginId) shared {
    /* auto r = _pluginId in references;
    if(r !is null) {
      r.release;
    } */
  }
  void unregister() shared {
    service = null;
    //foreach(r;references) {
    //}
  }
  this(string _pluginId="<unknown>",string[] typeId=[],string[string] props=null) shared {
    reg._regHandle = cast(shared(void*))this;
    reg.pluginId = _pluginId;
    reg.typeId = cast(shared(string[]))typeId.dup;
    if(props !is null) reg.properties = cast(shared(string[string]))props.dup;
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTCLASS] = reg.typeId[0];
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTTYPES] = reg.typeId.join(",");
    reg.properties[DXXConfig.serviceConstants.PROPERTY_PLUGINID] = reg.pluginId;
  }
  this(string _pluginId="<unknown>",string[] typeId=[],string[string] props=null) {
    reg._regHandle = cast(void*)this;
    reg.pluginId = cast(shared(string))_pluginId;
    reg.typeId = typeId.dup;
    if(props !is null) reg.properties = props.dup;
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTCLASS] = reg.typeId[0];
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTTYPES] = reg.typeId.join(",");
    reg.properties[DXXConfig.serviceConstants.PROPERTY_PLUGINID] = reg.pluginId;
  }
  /* string fullyQualifiedIdentifier() shared {
    //return reg.pluginId ~ "." ~ reg.id;
    return typeId[0];
  } */
}

final class TypeRegistration {
  string typeId;
  //Registration[][string] registrations;
  alias registry=Services.getRegistry;
  Registration[] registrations;

  nothrow
  void addRegistrations(shared(Registration)[]regs) shared {
    /*foreach(r;regs) {
       //if(r.pluginId !in registrations) {
        //registrations[r.pluginId]=[];
      //}
      //registrations[r.pluginId]~=cast(Registration)r;
      //registrations[]~=cast(Registration)r;
    }*/
    regs.each!(a=>addRegistration(a));
    //registrations.rehash;
  }
  nothrow
  void addRegistration(shared(Registration)reg) shared {
    //auto id = typeId ~ ":regs";
    /*auto regs = registry.get_ex!Registration[](id);
    if(regs.isnull) {
      registry.put!Registration[](id,[reg]);
    } else {
      registry.put!Registration[](id,regs.origin ~ [reg]);
    }*/
    registrations~=reg;
    //registrations.rehash;
  }

  void removeRegistration(shared(Registration) r) shared {
      /* if(r.pluginId !in registrations) return;
      registrations[r.pluginId] = registrations[r.pluginId].remove!(a=>a==cast(Registration)r);
      registrations.rehash; */
      //auto id = typeId ~ ":regs";
      //registry.remove(id);
      registrations = registrations.remove!(a=>a._regHandle == r._regHandle);
  }

  shared(Registration)[] lookupRegistrations(string typeId,string[string] matches=null) shared {
    /* if(typeId !in registrations) return [];
    if(matches is null || matches.length==0)return registrations[typeId];
    return registrations[typeId].filter!(a=>a.matches(matches)).array; */
    //auto id = typeId ~ ":regs";
    //auto regs = registry.get_ex!Registration[](id).filter!(a=>a.matches(matches));
    //return regs.array;
    return registrations.filter!(a=>a.matches(matches)).array;
  }
  nothrow
  this(string typeId="<unknown>",shared(Registration)[]regs=null) shared {
    this.typeId = typeId;
    if(regs !is null) {
      addRegistrations(regs);
    }
  }
  nothrow
  this() {
    this.typeId = "<unknown>";
  }
  nothrow
  this(shared(Registration)[]regs=null) shared {
    this("<unknown>",regs);
  }
}

final class Services {
  static
  shared(ServiceRegistration) registerService(string[] typeId,string pluginId,void* svc,string[string] props) {
    enforce(typeId.length > 0);
    shared(Registration) reg = new shared(Registration)(pluginId);
    reg.typeId = cast(shared(string[]))typeId.dup;
    reg.service = cast(shared(void*))svc;
    reg.properties = cast(shared(string[string]))props.dup;
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTCLASS] = typeId[0];
    reg.properties[DXXConfig.serviceConstants.PROPERTY_PLUGINID] = pluginId;
    reg.properties[DXXConfig.serviceConstants.PROPERTY_OBJECTTYPES] = typeId.join(",");
    typeId.each!(a=>addRegistration(a,reg));
    if(svc !is null) {
      if(cast(ServiceNotificationHandler*)svc is null) {
        // sendServiceEvent
      }
    }
    return reg;
  }
  static
  void unregisterService(shared(ServiceRegistration) reg) {
    //getRegistry.remove(pluginId ~ "." ~ reg.id);
    auto r = cast(shared(Registration*))reg._handle;
    if(r !is null) {
      foreach(t;r.typeId) {
        //getRegistry.remove(r.fullyQualifiedIdentifier);
        removeRegistration(t,*r);
      }
      r.unregister;
      auto svc = reg.service;
      if(svc !is null) {
        if(cast(ServiceNotificationHandler*)svc is null) {
          // sendServiceEvent
        }
      }
    }

  }
  static
  shared(ServiceReference)[] lookupReferences(string typeId,string pluginId,string[string] matches) {
    shared(ServiceReference)[] res;
    auto tr = getRegistry.get!(TypeRegistration)(typeId);
    if(!tr.isNull) {
      foreach(r;(cast(shared)(tr.origin)).lookupRegistrations(typeId,matches)) {
        res ~= r.createRef(pluginId);
      }
    }
    return res;
  }
  static
  shared(Registration)[] lookupRegistrations(string typeId,string[string] matches=null) {
    auto tr = getRegistry.get!(TypeRegistration)(typeId);
    if(!tr.isNull) {
      return (cast(shared)(tr.origin)).lookupRegistrations(typeId,matches);
    }
    return [];
  }
  static
  void* lookupService(ServiceReference reference) {
    auto r = cast(shared(Registration.Ref)) reference._handle;
    return cast(void*)r.service;
  }

  static __gshared BasicCache registry;

  static
  auto getRegistry() {
      static bool instantiated = false;
      if(!instantiated) {
          synchronized(Services.classinfo) {
              if(!registry) {
                //registry = CacheFectory.create;
                registry = new BasicCache;
              }
          }
          instantiated = true;
      }
      return registry;
  }


  static
  void addRegistration(const(string) typeId,shared(Registration) reg) {
    //getRegistry.put!(shared(Registration))(reg.fullyQualifiedIdentifier,reg);
    auto registry = getRegistry;
    auto r = registry.get!(shared(TypeRegistration))(typeId);
    if(r.isNull) {
      //registry.put!(Registration[],[cast(Registration)reg]);
      registry.set!(shared(TypeRegistration))(new shared(TypeRegistration)([reg]),typeId);
    } else {
      //registry.put!(Registration[], [ cast(Registration)reg ] ~ r);
      r.addRegistrations([reg]);
    }
    //auto r = ServiceEvent(cast(const(ServiceReference))reference);
    //Services.onRegistration(&r);
  }
  static
  void removeRegistration(const(string) typeId,shared(Registration) reg) {
    //getRegistry.put!(shared(Registration))(reg.fullyQualifiedIdentifier,reg);
    auto registry = getRegistry;
    auto tr = registry.get!(shared(TypeRegistration))(typeId);
    if(tr.isNull) {
      return;
    } else {
      //registry.put!(shared(Registration)[],r.remove!(a=>a==reg));
      tr.removeRegistration(reg);
      //auto r = ServiceEvent(cast(const(ServiceReference))reference);
      //Services.onRelease(&r);
    }
  }

  static void sendServiceEvent(ServiceNotification event) {
    auto registry = getRegistry;
    //auto tr = registry.get_ex!(TypeRegistration)(event.reference.typeId);
    //if(tr is null) return;
    //tr.send!ServiceEvent(event);
    string[string] matches = [
      DXXConfig.serviceConstants.NOTIFICATION_TYPEID : event.notificationType.to!string
    ];
    auto regs = lookupRegistrations(typeid(ServiceNotificationHandler).name,matches);
    //auto tr = registry.get_ex!(TypeRegistration);
    //(event.reference.typeId);
    foreach(r;regs) {
      synchronized(Services.classinfo) {
        auto h = cast(ServiceNotificationHandler*)r.service;
        if(h !is null) {
          h.handleServiceNotification(event);
        }
      }
    }
  }

}

final class PluginServices {

}
