module dxx.app.job;

interface Job {
    enum Status {
        NOT_STARTED,
        STARTED,
        PAUSED,
        TERMINATED,
        THROWN_EXCEPTION
    }
    @property
    Status status();

    @property
    bool terminated();

    @property
    Exception getThrownException();
    
    void execute();
    void join();
}

abstract class JobBase : Job {
    Status _status = Status.NOT_STARTED;
    Exception _thrownException;
    bool _terminated = false;
    @property
    Status status() {
        return _status;
    }
    @property
    bool terminated() {
        return _terminated;
    }
    @property
    Exception getThrownException() {
        return _thrownException;
    }
    void execute() {
        _status = Status.STARTED;
        try {
            executeJob();
            _status = Status.TERMINATED;
        } catch(Exception e) {
            _status = Status.THROWN_EXCEPTION;
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
