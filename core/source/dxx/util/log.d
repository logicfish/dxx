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
module dxx.util.log;

private import std.experimental.logger;
private import std.conv;

private import dxx.util;

/++
A notifying logger.
++/

final class MsgLog : SyncNotificationSource,NotificationListener {
    struct LogNotification {
        LogLevel logLevel;
        int line;
        string file;
        string funcName;
        string prettyFuncName;
        string moduleName;
        string msg;
    }
    __gshared shared(MsgLog) _MSGLOG;

    shared static this() {
        sharedLog.trace("MsgLog static this");
        if(_MSGLOG is null) {
            _MSGLOG = new MsgLog;
            _MSGLOG.addNotificationListener(_MSGLOG);
        }
    }

    override synchronized void handleNotification(void* p) {
        debug(Notify) {
            sharedLog.trace("MsgLog handleNotification");
        }
        //LogNotification* n = cast(LogNotification*)p;
        //if(n !is null) {
        //}
    }


    static auto logger() {
        if(InjectionContainer.getInstance is null) {
            return sharedLog;
        }
        return resolveInjector!Logger;
    }


    static void addLogNotificationListener(T)(T t) {
        _MSGLOG.addNotificationListener(t);
    }
    static void removeLogNotificationListener(T)(T t) {
        _MSGLOG.removeNotificationListener(t);
    }

    nothrow 
    static void sendLogNotification(LogNotification n) {
        _MSGLOG.send!(LogNotification)(&n);
    }

    nothrow 
    static void trace(int line = __LINE__, string file = __FILE__,
            string funcName = __FUNCTION__,
            string prettyFuncName = __PRETTY_FUNCTION__,
            string moduleName = __MODULE__, A...)(
                lazy A args) {
        try {
            sendLogNotification(LogNotification(LogLevel.trace,line,file,funcName,prettyFuncName,moduleName,args.to!string));
            logger.trace!(line,file,funcName,prettyFuncName,moduleName,A)(args);        
        } catch (Exception e) {
            //debug { // nothrow
            //    sharedLog.error(e);
            //}
        }
        
    }
    nothrow 
    static void warning(int line = __LINE__, string file = __FILE__,
            string funcName = __FUNCTION__,
            string prettyFuncName = __PRETTY_FUNCTION__,
            string moduleName = __MODULE__, A...)(
                lazy A args) {
        try {
            sendLogNotification(LogNotification(LogLevel.warning,line,file,funcName,prettyFuncName,moduleName,args.to!string));
            logger.warning!(line,file,funcName,prettyFuncName,moduleName,A)(args);
        } catch (Exception) {
        }
    }
    nothrow 
    static void error(int line = __LINE__, string file = __FILE__,
            string funcName = __FUNCTION__,
            string prettyFuncName = __PRETTY_FUNCTION__,
            string moduleName = __MODULE__, A...)(
                lazy A args) {
        try {
            sendLogNotification(LogNotification(LogLevel.error,line,file,funcName,prettyFuncName,moduleName,args.to!string));
            logger.error!(line,file,funcName,prettyFuncName,moduleName,A)(args);
        } catch (Exception) {
        }
    }
    nothrow 
    static void info(int line = __LINE__, string file = __FILE__,
            string funcName = __FUNCTION__,
            string prettyFuncName = __PRETTY_FUNCTION__,
            string moduleName = __MODULE__, A...)(
                lazy A args) {
        try {
            sendLogNotification(LogNotification(LogLevel.info,line,file,funcName,prettyFuncName,moduleName,args.to!string));
            logger.info!(line,file,funcName,prettyFuncName,moduleName,A)(args);
        } catch (Exception) {
        }
    }
    static void fatal(int line = __LINE__, string file = __FILE__,
            string funcName = __FUNCTION__,
            string prettyFuncName = __PRETTY_FUNCTION__,
            string moduleName = __MODULE__, A...)(
                lazy A args) {
        try {
            sendLogNotification(LogNotification(LogLevel.fatal,line,file,funcName,prettyFuncName,moduleName,args.to!string));
            logger.fatal!(line,file,funcName,prettyFuncName,moduleName,A)(args);
        } catch (Exception) {
        }
    }

};
