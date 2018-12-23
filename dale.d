import dl;

import std.file;
import std.stdio;
import std.string;
import std.process;

import dxx;
import ctini.ctini;

enum CFG = IniConfig!("dxx.ini");

immutable VERSION = packageVersion;

immutable PROJECTS = [
  "core","app","services","tool","examples/basic", "examples/plugin"
];
//immutable PROJECTS = DaleConfig.dale.projects;

immutable APPS = [
  "tool","examples/plugin","examples/basic"
];

immutable ARCH = CFG.build.dub.arch;

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
    /* exec("dub", ["test","--arch=x86_64","--root=core"]);
    exec("dub", ["test","--arch=x86_64","--root=app"]); */
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
    /* exec("dub", ["build","--root=tool","--arch=x86_64"]);
    exec("dub", ["build","--root=examples/basic","--arch=x86_64"]);
    exec("dub", ["build","--root=examples/plugin","--arch=x86_64"]); */
}

@(TASK)
void update() {
    foreach(p;PROJECTS) {
        exec("dub", ["upgrade","--root="~p]);
    }
    exec("dub", ["upgrade","--root=."]);
    /* exec("dub", ["update","--arch=x86_64"]);
    exec("dub", ["update","--root=core","--arch=x86_64"]);
    exec("dub", ["update","--root=app","--arch=x86_64"]);
    exec("dub", ["update","--root=tool","--arch=x86_64"]);
    exec("dub", ["update","--root=services","--arch=x86_64"]);
    exec("dub", ["update","--root=examples/basic","--arch=x86_64"]);
    exec("dub", ["update","--root=examples/plugin","--arch=x86_64"]); */
}

@(TASK)
void clean() {
  foreach(p;PROJECTS) {
      exec("dub", ["clean","--root="~p]);
  }
    //exec("dub", ["clean"]);
}

/** Generate documentation */
@(TASK)
void doc() {
//    exec("doxygen");
}

/** Run D-Scanner */
@(TASK)
void dscanner() {
    /* eachProject!(
      a=>exec("dub", ["run", "dscanner", "--root="~a, "--", "--styleCheck"])
    )();
    */
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
