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
module dxx.util.notify;

private import std.algorithm;
private import std.parallelism;

private import std.experimental.logger;

/++
Simple notification service.

An object that inherits NotificationSource maintains a vector of
NotificationListener's.

At any time the listeners callback method handleNotification may be invoked.
If the client implements the interface ASyncNotificationListener then the
invocations should be in parallel.


++/

interface NotificationListener {
  shared void handleNotification(void* t);
}

interface ASyncNotificationListener : NotificationListener {
}

interface NotificationSource {
  shared void addNotificationListener(shared(NotificationListener) n);
  shared void removeNotificationListener(shared(NotificationListener) n);
}

abstract class NotificationListenerBase(T) : NotificationListener {
  abstract shared void handle(T* t);
  shared void handleNotification(void* t) {
    this.handle(cast(T*)t);
  }

}

/++

Synchronized notification handler. Extend this class to create an object that can send
notifications to a group of listeners.

++/
class SyncNotificationSource : NotificationSource {
  shared shared(NotificationListener)[] _listenersAsync;
  shared shared(NotificationListener)[] _listeners;

  shared void addNotificationListener(shared(NotificationListener) n) {
    if(cast(shared(ASyncNotificationListener)) n is null) {
        debug(Notify) {
            info(typeid(this)," : addNotificationListener sync ",_listeners.length," ");
        }
        _listeners ~= n;
    } else {
        debug(Notify) {
            info(typeid(this)," : addNotificationListener async ",_listeners.length," ");
        }
        _listenersAsync ~= n;
    }
  }

  shared void removeNotificationListener(shared(NotificationListener) n) {
    if(cast(shared(ASyncNotificationListener)) n is null) {
        debug(Notify) {
            info(typeid(this)," : removeNotificationListener ",_listeners.length);
        }
        _listeners = _listeners.remove(_listeners.countUntil(n));
    } else {
        debug(Notify) {
            info(typeid(this)," : removeNotificationListener async",_listenersAsync.length);
        }
        _listenersAsync = _listenersAsync.remove(_listenersAsync.countUntil(n));
    }
  }

//    shared(Notifier) notifier;
//    alias notifier this;

    @property
    nothrow shared ref
    auto listeners() {
      return _listeners;
    }

    @property
    nothrow shared ref inout
    auto listenersAsync() {
      return _listenersAsync;
    }

    protected
    nothrow
    void _send(T)(T* t) {
      (cast(shared)this).send(t);
    }
    nothrow shared
    void send(T)(T* t) {
    assert(t);
    debug(Notify) {
        try {
            info("SyncNotificationSource : send ",listeners.length);
        } catch(Exception e) {
            //error(e.message);
        }
    }
    //shared(NotificationListener)[] ar = listeners.dup;
    auto ar = _listeners.dup;
    foreach(x;ar) {
        try {
            debug(Notify) {
                info("sync notification");
            }
            x.handleNotification(cast(void*)t);
        } catch(Exception e) {
            try {
                error(e.message);
            } catch(Exception) {
            }
        }
    }
    auto ar2 = _listenersAsync.dup;
    try {
        foreach(x;ar2.parallel) {
            //assert(x);
            debug(Notify) {
                sharedLog.info("async notification ",typeid(x));
            }
            x.handleNotification(cast(void*)t);
        }
    } catch(Exception e) {
        try {
            sharedLog.error(e.message);
        } catch(Exception) {
        }
    }
    }
}

unittest {
    shared(bool) done = false;
    class TestNotificationListener : NotificationListener {
        override shared void handleNotification(void* t) {
            done = true;
        }
    }
    auto n = new shared(SyncNotificationSource);
    shared(NotificationListener) l = new shared(TestNotificationListener);
    n.addNotificationListener(l);
    string s = "";
    n.send!string(&s);
    assert(done is true);

    done = false;
    n.removeNotificationListener(l);
    n.send!string(&s);
    assert(done is false);
}

unittest {
    import core.thread;

    shared(bool) done = false;
    class TestNotificationListener : NotificationListener,ASyncNotificationListener {
        override shared void handleNotification(void* t) {
            done = true;
        }
    }
    auto n = new shared(SyncNotificationSource);
    shared(NotificationListener) l = new shared(TestNotificationListener);
    n.addNotificationListener(l);
    string s = "";
    n.send!string(&s);
    Thread.sleep(dur!("msecs")( 500 ));
    assert(done is true);

    done = false;
    n.removeNotificationListener(l);
    n.send!string(&s);
    Thread.sleep(dur!("msecs")( 500 ));
    assert(done is false);
}

unittest {
    class TestHandler {
        bool done = false;
    }
    class TestNotificationListener : NotificationListener {
        override shared void handleNotification(void* t) {
            assert(t);
            auto a = cast(TestHandler*)t;
            assert(a);
            a.done = true;
        }
    }
    auto n = new shared(SyncNotificationSource);
    shared(NotificationListener) l = new shared(TestNotificationListener);
    TestHandler testHandler = new TestHandler;

    n.addNotificationListener(l);
    //string s = "";
    n.send(&testHandler);
    assert(testHandler.done is true);

    testHandler.done = false;
    n.removeNotificationListener(l);
    n.send(&testHandler);
    assert(testHandler.done is false);
}
