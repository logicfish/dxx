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
module dxx.app.component;

private import aermicioi.aedi;

private import core.runtime;

private import std.experimental.logger;
private import std.exception;

private import dxx.util.injector;
private import dxx.util.config;
private import dxx.app;

interface Components {
    public Logger getLogger();
}

mixin template registerComponent(T : RuntimeComponents!Param,Param...) {
    shared static this() {
        import std.conv;
        import std.experimental.logger;
        import dxx.util.injector;

        debug(Component) { sharedLog.info("RuntimeComponents register "~typeid(T).to!string); }
        auto t = new T;
    }
}


mixin template registerComponents(Param...) {
    mixin registerComponent!(RuntimeComponents!Param);
}

@component
class RuntimeComponents(Param...) : Components {
//    static ArgParser argParser;

    static __gshared InjectionContainer _injector;
    static bool instantiated = false;

    this(this T)() {
        debug(Component) {
            import std.conv;
            sharedLog.info("RuntimeComponents "~typeid(T).to!string);
        }
        synchronized(InjectionContainer.classinfo) {
            if(!instantiated) {
                if(_injector is null) {
                    _injector = newInjector!(T,Param);
                    registerAppDependencies(_injector);
                    _injector.instantiate();
                }
                instantiated = true;
            }
        }
    }

    void registerAppDependencies(InjectionContainer injector) {
        //
    }

    public {

        @component
        override Logger getLogger() {
            return sharedLog;
        }
    }


}
