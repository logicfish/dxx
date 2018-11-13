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

++/

interface NotificationListener {
  shared void handleNotification(void* t);
};

interface NotificationSource {
  shared void addNotificationListener(shared(NotificationListener) n);
  shared void removeNotificationListener(shared(NotificationListener) n);
}

/++
Synchronized notification handler.
++/

class SyncNotificationSource : NotificationSource {

  NotificationListener[] notificationListeners;

  nothrow shared
  void send(T)(T* t) {
    debug(Notify) {
        sharedLog.info("SyncNotificationSource : send ",typeid(T)," ",notificationListeners.length);
    }
    auto ar = notificationListeners.dup;
    try {
      ar.parallel.each!(x=>x.handleNotification(cast(void*)&t));
    } catch(Exception e) {
      //sharedLog.error(e.message); nothrow!
    }
  }

  override shared void addNotificationListener(shared(NotificationListener) n) {
    debug(Notify) {
        sharedLog.info("SyncNotificationSource : addNotificationListener ",notificationListeners.length);
    }
    notificationListeners ~= n;
  }

  override shared void removeNotificationListener(shared(NotificationListener) n) {
    debug(Notify) {
        sharedLog.info("SyncNotificationSource : removeNotificationListener",notificationListeners.length);
    }
    notificationListeners = notificationListeners.remove(notificationListeners.countUntil(n));
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
