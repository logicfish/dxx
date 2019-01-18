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
module dxx.sys.shellcmd;

private import std.path;
private import std.conv;
private import std.exception;

private import dxx.util;
private import dxx.sys.spawn;
private import dxx;

class LoggingWriter : TextWriter {
  string prefix;
  this(string p) {
    prefix = p;
  }
  void writeText(dstring text) {
    MsgLog.info(MsgParam!("[%s]: %s")(prefix,text));
  }
}

void shellCmd(string cmd,string[] param) {
    auto exec = cmd.findExecutablePath;
    //auto stdOutWriter = new ProtectedTextStorage();
    auto stdOutWriter = new LoggingWriter(cmd);
    auto stdErrWriter = new LoggingWriter(cmd);
    auto proc = new ExternalProcess();
    proc.run(exec,param,runtimeConstants.curDir,stdOutWriter,stdErrWriter);
    proc.wait();
    enforce(proc.state == ExternalProcessState.Stopped);
    enforce(proc.result == 0);
    //return proc.result;
}

unittest {
  MsgLog.info(shellCmd("dub",["describe"]));
}
