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
};

interface ASyncNotificationListener : NotificationListener {
};

interface NotificationSource {
  shared void addNotificationListener(shared(NotificationListener) n);
  shared void removeNotificationListener(shared(NotificationListener) n);
}

/++

Synchronized notification handler. Extend this class to create an object that can send
notifications to a group of listeners.

++/

class SyncNotificationSource : NotificationSource {

  NotificationListener[] notificationListeners;

  nothrow shared
  void send(T)(T* t) {
    debug(Notify) {
        try {
            sharedLog.info("SyncNotificationSource : send ",typeid(T)," ",notificationListeners.length);
        } catch(Exception) {
        }
    }
    //auto ar = notificationListeners.dup;
    alias ar = notificationListeners;
    
    ar.filter!(x=>cast(shared(ASyncNotificationListener))x  is null).each!( x=>{
        try {
            debug(Notify) {
                sharedLog.info("sync notification ",typeid(x));
            }
            x.handleNotification(cast(void*)&t);
        } catch(Exception e) {
            try {
                sharedLog.error(e.message);
            } catch(Exception) {
            }
        }
    });
    try {
        ar.filter!(x=>cast(shared(ASyncNotificationListener))x !is null).parallel.each!(
            //debug(Notify) {
            //    sharedLog.info("async notification ",typeid(x));
            //}
            x=>x.handleNotification(cast(void*)&t)
        );
    } catch(Exception e) {
        try {
            sharedLog.error(e.message);
        } catch(Exception) {
        }
    }
  }

  override shared void addNotificationListener(shared(NotificationListener) n) {
    notificationListeners ~= n;
    debug(Notify) {
        sharedLog.info(typeid(this)," : addNotificationListener ",notificationListeners.length," ");
    }
  }

  override shared void removeNotificationListener(shared(NotificationListener) n) {
    notificationListeners = notificationListeners.remove(notificationListeners.countUntil(n));
    debug(Notify) {
        sharedLog.info(typeid(this)," : removeNotificationListener",notificationListeners.length);
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
