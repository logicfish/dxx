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
module dxx.app.log;

private import std.experimental.logger;

private import dxx.util;

class MsgLog {

    //static void trace(alias m,Args...)(Args a) {
    //    trace(MsgText!m)(a);
    //}

    static void trace(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.trace(m);
    }

    //static void log(alias m,Args...)(Args a) {
    //    log(MsgText!m)(a);
    //}

    static void log(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.log(m);
    }

    //static void warn(alias m,Args...)(Args a) {
    //    warn(MsgText!m)(a);
    //}

    static void warn(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.warn(m);
    }

    //static void error(alias m,Args...)(Args a) {
    //    error(MsgText!m)(a);
    //}

    static void error(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.error(m);
    }

    //static void info(alias m,Args...)(Args a) {
    //    info(MsgText!m)(a);
    //}

    static void info(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.info(m);
    }
    //static void fatal(alias m,Args...)(Args a) {
    //    fatal(MsgText!m)(a);
    //}

    static void fatal(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.fatal(m);
    }
};
