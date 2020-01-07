/**
Copyright: 2018 Mark Fisher

License:
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

private import dxx.util;
private import dxx.app;

/++
Represents a task to run once in a single thread.
Notifications are sent when the job state changes.
++/
interface Job : NotificationSource {
    enum Status {
        NOT_STARTED,
        STARTED,
        SUSPENDED,
        TERMINATED,
        THROWN_EXCEPTION
    }
    struct JobStatusEvent {
      shared(Job) job;
      Status status;
    }

    @property pure @safe nothrow @nogc shared
    const(Status) status() const;

    @property pure @safe nothrow @nogc shared
    bool terminated() const;

    @property pure @safe nothrow @nogc shared
    ref inout(shared(Exception))
    thrownException() inout;

    nothrow shared
    void execute();

}

/++
A simple default class for clients to use.
The method `process` should be overriden.
++/
abstract class JobBase : SyncNotificationSource, Job {
    Status _status = Status.NOT_STARTED;
    shared(Exception) _thrownException;

    @property pure @safe nothrow @nogc shared
    const(Status) status() const {
        return _status;
    }
    @property nothrow shared
    void status(Status s) {
      _status = s;
      auto e = JobStatusEvent(this,s);
      (cast(shared)this).send!JobStatusEvent(&e);
    }
    @property pure @safe nothrow @nogc shared
    bool terminated() const {
        return (status == Status.TERMINATED) || (status == Status.THROWN_EXCEPTION);
    }
    @property @safe nothrow shared
    ref inout(shared(Exception)) thrownException() inout {
        return _thrownException;
    }

    nothrow
    void execute() shared {
        try {
            enforce(_status == Status.NOT_STARTED);
            setup;
            status(Status.STARTED);
            process;
            status = Status.TERMINATED;
        } catch(Exception e) {
            MsgLog.error(e.file,":",e.line,"-",e.message);
            _thrownException = cast(shared(Exception))e;
            status = Status.THROWN_EXCEPTION;
            version(Posix) {
              import backtrace;
              import std.stdio;
              try {
                printPrettyTrace(stderr);
              } catch(Throwable t) {
              }
            } else {
              MsgLog.info("[Exception]",e.info);
            }
        } finally {
            terminate;
        }
    }

    static void join(shared(Job) j) {
        while(!j.terminated) {
            Thread.sleep( dur!("msecs")( 10 ) );
        }
    }

    void setup() shared {}

    abstract void process() shared;

    nothrow void terminate() shared {}

}

class JobDelegate(alias F) : JobBase {
    override void process() {
        F();
    }
}
