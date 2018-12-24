import dl;

import std.file;
import std.stdio;
import std.string;
import std.process;

import dxx;
import ctini.ctini;

enum CFG = IniConfig!("dale.ini");
pragma(msg,CFG);

immutable VERSION = packageVersion;

immutable PROJECTS = CFG.build.projects.split(',');

immutable APPS = CFG.build.apps.split(',');

immutable ARCH = CFG.build.arch;

void eachApp(T)() {
  foreach(a;APPS) {
      T(a);
  }
}

void eachProject(T)() {
  foreach(p;PROJECTS) {
      T(a);
  }
}

@(TASK)
void banner() {
    writefln("dxx %s", VERSION);
}

@(TASK)
void test() {
    exec("dub", ["test","--arch=x86_64"]);
    foreach(p;PROJECTS) {
        exec("dub", ["test","--arch="~ARCH,"--root="~p]);
    }
}

@(TASK)
void build() {
    deps(&test);
    exec("dub", ["build","--arch="~ARCH]);
    foreach(a;APPS) {
       exec("dub", ["build","--root="~a,"--arch="~ARCH]);
    }
}

@(TASK)
void update() {
    exec("git", ["pull"]);
}

@(TASK)
void upgrade() {
    foreach(p;PROJECTS) {
        exec("dub", ["upgrade","--root="~p]);
    }
    exec("dub", ["upgrade","--root=."]);
}

@(TASK)
void clean() {
  foreach(p;PROJECTS) {
      exec("dub", ["clean","--root="~p]);
  }
  exec("dub", ["clean","--root=."]);
}

/** Generate documentation */
@(TASK)
void doc() {
//    exec("doxygen");
}

/** Run D-Scanner */
@(TASK)
void dscanner() {
    exec("dscanner");
}

/** Static code validation */
@(TASK)
void lint() {
    // deps(&doc);
    deps(&dscanner);
}

/** Lint, and then install artifacts */
@(TASK)
void install() {
    auto cwd = getcwd();
    exec("dub", ["add-local", cwd]);
}

/** Uninstall artifacts */
@(TASK)
void uninstall() {
    auto cwd = getcwd();
    wait(execMut("dub", ["remove-local", cwd]).pid);
}


//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
