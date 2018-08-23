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
