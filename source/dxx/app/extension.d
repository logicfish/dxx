module dxx.app.extension;

private import std.algorithm;
private import dxx.util;

struct ExtensionPointDesc {
    string id;
    string symbolicName;
    string description;
    string url;    
}

interface ExtensionPoint {
    const(string) id();
    inout(ExtensionPointDesc) desc() inout;
}

struct ExtensionDesc {
    string id;
    string symbolicName;
    string extensionPoint;
    string description;
    string url;    
}

interface Extension {
    const(string) id();
    inout(ExtensionDesc) desc() inout;
}

class ExtensionPointManager {
    Extension[] extensions;
    void enumerateExtensions(alias T)(string xp) {
        extensions.filter!(a => a.desc.extensionPoint == xp).each!(a => T(a));
    }
}
