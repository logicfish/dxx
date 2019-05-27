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
module dxx.app.procjob;

private import dxx.sys.spawn;
private import dxx.app;
private import dxx.util;
private import dxx;

/**
 * This class defines a notifying job that starts a native process.
 */
class ProcessJob : PlatformJobBase {

    static class StdIOWriter : TextWriter {
        string prefix;
        shared
        this(string p) {
            prefix = p;
        }
        void writeText(dstring text) {
            MsgLog.info(MsgParam!("[%s]: %s")(prefix,text));
        }
    }
    string cmd;
    string[] param;
    string result;

    protected ExternalProcess proc;
    protected TextWriter stdErrWriter;
    protected TextWriter stdOutWriter;

    override shared
    void setup() {
        super.setup;
    }

    override shared
    void processPlatformJob() {
        (cast(ProcessJob)this).shell;
    }

    nothrow
    override shared
    void terminate() {
        if(proc) {
            try {
                (cast(ExternalProcess)proc).wait;
                //enforce(proc.state == ExternalProcessState.Stopped);
            } catch(Throwable e) {
                MsgLog.error(e.message);
            }
        }
        super.terminate;
    }
    shared
    this(string cmd,string[] param) {
        super();
        this.cmd = cmd;
        this.param = (cast(shared(string[]))param).dup;
        this.stdOutWriter = new shared(StdIOWriter)(cmd);
        this.stdErrWriter = new shared(StdIOWriter)(cmd ~ ":err");
        this.proc = cast(shared(ExternalProcess))new ExternalProcess();
    }
    auto shell() {
        auto exec = cmd.findExecutablePath;
        //auto stdOutWriter = new ProtectedTextStorage();
        //auto stdOutWriter = new Logg7ingWriter(cmd);
        return proc.run(exec,param,runtimeConstants.curDir,stdOutWriter,stdErrWriter);
        //proc.wait();
        //enforce(proc.state == ExternalProcessState.Stopped);
        //enforce(proc.result == 0);
        //return proc.result;
        //return stdOutWriter.readText();
    }
}

unittest {
    import std.stdio;
    auto j = new shared(ProcessJob)("ls",["-lh"]);
    j.execute();
    assert(j.terminated);
    writeln("Job status: ",j.status);
    assert(j.status == Job.Status.THROWN_EXCEPTION);
    assert(j.thrownException !is null);
}

