module dxx.app.job;

private import dxx.util;

interface Job : NotificationSource {
    enum Status {
        NOT_STARTED,
        STARTED,
        PAUSED,
        TERMINATED,
        THROWN_EXCEPTION
    }
    struct JobStatusEvent {
      Job job;
      Status status;
    }

    @property
    Status status();

    @property
    bool terminated();

    @property
    Exception thrownException();

    void execute();
    void join();
}

abstract class JobBase : SyncNotificationSource, Job {
    Status _status = Status.NOT_STARTED;
    Exception _thrownException;
    bool _terminated = false;
    @property
    Status status() {
        return _status;
    }
    @property
    void status(Status s) {
      _status = s;
      (cast(shared)this).send!JobStatusEvent(JobStatusEvent(this,s));
    }
    @property
    bool terminated() {
        return _terminated;
    }
    @property
    Exception thrownException() {
        return _thrownException;
    }
    void execute() {
        status(Status.STARTED);
        try {
            executeJob();
            status = Status.TERMINATED;
        } catch(Exception e) {
            status = Status.THROWN_EXCEPTION;
            _thrownException = e;
        } finally {
            _terminated = true;
        }
    }
    void join() {
        while(!terminated) {
        }
    }
    abstract void executeJob();
}

class JobDelegate(alias F) : JobBase {
    override void executeJob() {
        F(this);
    }
}
