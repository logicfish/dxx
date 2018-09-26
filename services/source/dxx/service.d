module dxx.service;

import std.variant;
import dxx.util.notify;

interface Service {
    void start(const(Variant[string])param);
    void stop();
}

struct ServiceNotification {
    enum Status {
        STARTED,
        STOPPED,
        ERROR
    }
    Status status;
    Service service;
}

class ServiceBase : SyncNotificationSource, Service {
    void sendServiceNotification(ServiceNotification n) {
        (cast(shared)this).send!ServiceNotification(&n);
    }
    override void start(const(Variant[string])param) {
        auto n = ServiceNotification(ServiceNotification.Status.STARTED,this);
        sendServiceNotification(n);
        onStart();
    }
    override void stop() {
        auto n = ServiceNotification(ServiceNotification.Status.STOPPED,this);
        sendServiceNotification(n);
        onStop();
    }
    void onStart(){}
    void onStop(){}
}