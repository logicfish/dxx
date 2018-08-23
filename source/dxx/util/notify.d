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
