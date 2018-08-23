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
module dxx.util.injector;

private import aermicioi.aedi;

private import std.stdio;
private import std.experimental.logger;

static string[string] readInjectorProperties(File* f) {
    string[string] res;
    return res;
}

static void registerInjectorProperties(string[string] properties) {
}

static auto resolveInjector(alias T,Arg...)(Arg arg) {
    return DefaultInjector._DEFAULT_CONTAINER.locate!T(arg);
}

static auto newInjector(alias T)(ConfigurableContainer c = DefaultInjector._DEFAULT_CONTAINER) {
    return new ContextInjector!T(c);
}

abstract class DefaultInjector {

        static __gshared ConfigurableContainer _DEFAULT_CONTAINER;

        @property
        ConfigurableContainer container;

        shared static this() {
            debug {
                sharedLog.info("Creating shared container.");
            }
            _DEFAULT_CONTAINER = prototype();
            scope(exit) _DEFAULT_CONTAINER.terminate();
        }
        this(ConfigurableContainer c = _DEFAULT_CONTAINER) {
            container = c;
        }
        void registerProperties(string[string] properties) {
        }
        auto resolve(alias T)() {
            return container.locate!T;
        }
        void register(T...)() {
            container.register!T;
        }
        auto configure() {
            return container.configure;
        }
        auto instantiate() {
            return container.instantiate;
        }
}


final class ContextInjector(alias C ) : DefaultInjector {
    this(ConfigurableContainer c = _DEFAULT_CONTAINER) {
        super(c);
        c.scan!C;
    }
}
