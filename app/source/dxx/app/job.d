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

private import std.exception;

private import core.thread;

private import hunt.cache;

private import dxx.util;
private import dxx.app;

interface Job : NotificationSource {
    enum Status {
        NOT_STARTED,
        STARTED,
        SUSPENDED,
        TERMINATED,
        THROWN_EXCEPTION
    }
    struct JobStatusEvent {
      Job job;
      Status status;
    }

    @property pure @safe nothrow @nogc
    const(Status) status() const;

    @property pure @safe nothrow @nogc
    bool terminated() const;

    @property pure @safe nothrow @nogc
    ref inout(Exception) thrownException() inout;

    nothrow
    void execute();

}

abstract class JobBase : SyncNotificationSource, Job {
    Status _status = Status.NOT_STARTED;
    Exception _thrownException;

    UCache cache;

    @property pure @safe nothrow @nogc
    const(Status) status() const {
        return _status;
    }
    @property nothrow
    void status(Status s) {
      _status = s;
      auto e = JobStatusEvent(this,s);
      (cast(shared)this).send!JobStatusEvent(&e);
    }
    @property pure @safe nothrow @nogc
    bool terminated() const {
        return (status == Status.TERMINATED) || (status == Status.THROWN_EXCEPTION);
    }
    @property @safe nothrow
    ref inout(Exception) thrownException() inout {
        return _thrownException;
    }

    nothrow
    void execute() {
        try {
            enforce(_status == Status.NOT_STARTED);
            setup;
            status(Status.STARTED);
            process;
            status = Status.TERMINATED;
        } catch(Exception e) {
            MsgLog.warning("Exception: " ~ e.message);
            _thrownException = e;
            status = Status.THROWN_EXCEPTION;
        } finally {
            terminate;
        }
    }

    static void join(const(Job) j) {
        while(!j.terminated) {
            Thread.sleep( dur!("msecs")( 10 ) );
        }
    }

    void setup() {}

    abstract void process();

    nothrow void terminate() {}

    T getProperty(T)(string id) {
        return cache.put!T(id);
    }
    void setProperty(T)(T t,string id) {
        cache.put!T(id,t);
    }

    this() {
      cache = UCache.CreateUCache();
    }
}

class JobDelegate(alias F) : JobBase {
    override void process() {
        F();
    }
}
