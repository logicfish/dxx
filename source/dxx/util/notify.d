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

class NotificationListener {
  synchronized void handleNotification(T)(T t) {
  }
};

interface NotificationSource {
  synchronized void addNotificationListener(shared(NotificationListener) n);
  synchronized void removeNotificationListener(shared(NotificationListener) n);
}

/++
Synchronized notification handler.
++/

//template removeElement(alias T,alias V) {
//  auto ref removeElement(ref V v) { return v.remove(a => a is T); }
//}

class SyncNotificationSource : NotificationSource {
  NotificationListener[] notificationListeners;
  synchronized void send(T)(T t) {
    notificationListeners.parallel.each!(x=>x.handleNotification!T(t));
  }
  override shared void addNotificationListener(shared(NotificationListener) n) {
    notificationListeners ~= n;
  }
  override shared void removeNotificationListener(shared(NotificationListener) n) {
  //notificationListeners.remove(notificationListeners.countUntil(n));
    notificationListeners.remove!(a => a is n);
    //notificationListeners.removeElement!n;
  }
}
