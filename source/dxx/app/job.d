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

private import core.thread;

private import dxx.util;
private import dxx.app;

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

    @property pure @safe nothrow @nogc
    const(Status) status() const;

    @property pure @safe nothrow @nogc
    bool terminated() const;

    @property pure @safe nothrow @nogc
    ref inout(Exception) thrownException() inout;

    void execute();
    //void join();
	//void setProperty(string k,string v);
	//string getProperty(string k);
}

abstract class JobBase : SyncNotificationSource, Job {
    Status _status = Status.NOT_STARTED;
    Exception _thrownException;
    bool _terminated = false;
    DefaultInjector _injector;
    
    @property pure @safe nothrow @nogc
    const(Status) status() const {
        return _status;
    }
    @property
    void status(Status s) {
      _status = s;
      auto e = JobStatusEvent(this,s);
      (cast(shared)this).send!JobStatusEvent(&e);
    }
    @property pure @safe nothrow @nogc
    bool terminated() const {
        return _terminated;
    }
    @property @safe nothrow
    ref inout(Exception) thrownException() inout {
        return _thrownException;
    }
    @property @safe nothrow
    ref inout(DefaultInjector) injector() inout {
    	return _injector;
    }

    nothrow
    void execute() {
        try {
        	_injector = RuntimeModule.injector; 
            status(Status.STARTED);
            executeJob();
            status = Status.TERMINATED;
        } catch(Exception e) {
            _thrownException = e;
            try {
              MsgLog.warning(e.message);
              status = Status.THROWN_EXCEPTION;
            } catch(Exception _e) {
              MsgLog.error(_e.message);
            } finally {}
        } finally {
            _terminated = true;
        }
    }

    static void join(const(Job) j) {
        while(!j.terminated) {
            Thread.sleep( dur!("msecs")( 10 ) );
        }
    }
    abstract void executeJob();
//	override void setProperty(T)(string k,T v) {
//		injector.setProperty(v,k);
//	}    
//	override T getProperty(T)(string k) {
//		return injector.getProperty!T(k);
//	}   
	//override 
	void setProperty(string k,string v) {
		injector.register!string(v,k);
	}    
	//override 
	string getProperty(string k) {
		return injector.resolve!string(k);
	}   
}

class JobDelegate(alias F) : JobBase {
    override void executeJob() {
        F();
    }
}
