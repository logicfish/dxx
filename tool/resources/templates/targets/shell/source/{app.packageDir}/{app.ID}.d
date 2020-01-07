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
module dxx.example.basic.app;

private import ctini.ctini;
private import aermicioi.aedi;

private import std.stdio;
private import std.experimental.logger;
private import std.conv;
private import std.string;
private import std.file;

private import dxx.app;
private import dxx.util;

enum CFG = DXXConfig ~ IniConfig!"{{app.applicationID}}.ini";

mixin __Text!(CFG.basic.lang);

class Example {
};

alias BasicParam = Tuple!(
        string,"name",
        uint,"age",
        PluginDef,"plugins"
);

/*
@component
class BasicComponents : RuntimeComponents!BasicParam {
    override void registerAppDependencies(InjectionContainer injector) {
        debug {
            sharedLog.info("BasicComponents registerAppDependencies()");
        }
    }
    shared static this() {
        new BasicComponents;
    }
    mixin registerComponent!BasicComponents;
};
*/

mixin registerComponent!(PlatformRuntime!BasicParam);


int main(string[] args) {
    //scope(exit)terminateInjector;

    //auto m = new BasicComponents;
    debug {
        sharedLog.info("basic main");
    }
    MsgLog.info(MsgText!(CFG.basicMessages.MSG_APP_BANNER));
//    MsgLog.info("name = " ~ getInjectorProperty!string("name"));
//    MsgLog.info("age = " ~ (getInjectorProperty!uint("age")).to!string);
    string n =  getInjectorProperty!string("name");
    MsgLog.info("name = " ~ n);
    //sharedLog.info("name = " ~ getInjectorProperty!string("name"));
    auto age = (getInjectorProperty!uint("age"));
    MsgLog.info("age = " ~ age.to!string);

    /*version(Posix) {
        l.load("examples/plugin/bin/libdxx_plugin.so");
    } else version(Windows) {
        l.load("examples/plugin/bin/dxx_plugin.dll");
    } else {
        // ...
    }*/
    auto paths = getInjectorProperty!string(CFG.keys.pluginDirs);
    MsgLog.info(CFG.keys.pluginDirs ~ " = " ~ paths);
    /*auto plugin = "dxx_plugin";

    foreach(p;paths.split(',')) {
      MsgLog.info("Path: " ~ p);
      if(PluginLoader.pluginFileName(plugin,p).exists) {
        MsgLog.info("Load: dxx_plugin");
        l.load(plugin,p);
        break;
      }
    }*/

    //auto plugins = getInjectorProperty!(PluginDef[])("plugins");
    auto plugin = getInjectorProperty!(PluginDef)("plugins");
    //auto plugin=Tuple!(string,"name")("dxx_plugin");

    //foreach(plugin;plugins) {
      foreach(path;paths.split(',')) {
        if(PluginLoader.pluginFileName(plugin.name,path).exists) {
          MsgLog.info("Load: "~plugin.name);
          auto l = resolveInjector!PluginLoader();
          assert(l);
          l.load(plugin.name,path);
          l.update;
          scope(exit)destroy(l);
        }
      }
    //}

    MsgLog.info("Done.");
    return 0;
}
