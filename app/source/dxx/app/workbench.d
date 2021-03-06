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
module dxx.app.workbench;

private import std.exception;

/* private import hunt.cache; */

private import dxx.util;

private import dxx.app.resource.workspace;
private import dxx.app.job;
private import dxx.app.platform;

/++
The Workbench provides a framework for synchronizing job access to
platform resources.

Only one single workbench job can run over a particular
workbench. The `waitLock` method blocks until the previous job has
terminated.  The `lock` method throws an exception if the previous job
has not terminated.

The idea is that we don't have to worry about serializing access to the
underlying resources (for example, the Workspace). We can create
instances of WorkbenchJob and execute these in a thread pool - the
workbench ensures that no conflicts occur.
+/
interface Workbench {
    static Workbench getCurrent() {
        return resolveInjector!Workbench("app.workbench");
    }
    //Workbench getWorkbench();
    void lock(shared(WorkbenchJob)) shared;
    void unlock(shared(WorkbenchJob)) shared;
    void waitLock(shared(WorkbenchJob)) shared;
    bool isLocked() shared;
}

final class WorkbenchDefault :
              SyncNotificationSource, Workbench {
    /* UCache resourceCache;
    this() {
        resourceCache = UCache.CreateUCache();
    } */
    shared(WorkbenchJob)* currentJob;
    shared
    void lock(shared(WorkbenchJob) j) {
      enforce(this.currentJob is null);
      this.currentJob = &j;
    }
    shared
    void unlock(shared(WorkbenchJob) j) {
      enforce(this.currentJob == &j);
      this.currentJob = null;
    }
    shared
    void waitLock(shared(WorkbenchJob) j) {
      while(currentJob !is null) {
        JobBase.join(*currentJob);
      }
      lock(j);
    }
    shared
    bool isLocked() {
      return (currentJob is null);
    }
}

class WorkbenchJob : PlatformJobBase {
  override shared
  void processPlatformJob() {
    workbench.waitLock(this);
    scope(exit)workbench.unlock(this);
    processWorkbenchJob;
  }
  override
  void setup() shared {
    DXXPlatform.clearLocalCache;
    super.setup;
  }
  abstract shared
  void processWorkbenchJob();
}

class WorkbenchJobDefault : WorkbenchJob {
  Job job;
  shared this(shared(Job) j) {
    enforce(cast(WorkbenchJob)j is null);
    this.job = j;
  }
  override shared
  void processWorkbenchJob() {
    job.execute;
  }
}
