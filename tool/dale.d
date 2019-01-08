import dl;

private import aermicioi.aedi;
private import ctini.ctini;

private import std.file;
private import std.stdio;
private import std.string;
private import std.process;

private import dxx.util;
private import dxx.app;
private import dxx.tools;
private import dxx.app.platform;

// Compile-time config
enum DaleConfig = DXXConfig ~ IniConfig!("dale.ini");

@component
class ToolsDevModule : PlatformRuntime!() {
  mixin __Text!(DaleConfig.build.lang);

  mixin registerComponent!ToolsDevModule;
}

immutable VERSION = packageVersion;

//immutable PROJECTS = CFG.build.projects.split(',');
//immutable APPS = CFG.build.apps.split(',');

//immutable ARCH = ToolConfig.dale.arch;
//immutable DEBUGS = ToolConfig.dale.debugs;
//immutable CONFIG = ToolConfig.build.config;
//immutable BUILD = ToolConfig.build.build;

template __lookup(T,string v) {
  auto __lookup() {
    return __c.locate!T(v);
  }
}

/*template ARCH() {
  auto ARCH() { return __c.locate!string("build.arch"); }
}
template BUILD() {
  auto BUILD() { return __c.locate!string("build.build"); }
}
template DEBUGS() {
  auto DEBUGS() { return __c.locate!(string[])("build.debug"); }
}
template CONFIG() {
  auto CONFIG() { return __c.locate!string("build.config"); }
}*/
immutable ARCH=DaleConfig.build.arch;
immutable BUILD=DaleConfig.build.build;
immutable CONFIG=DaleConfig.build.config;

@(TASK)
void banner() {
    writefln("dxx tool %s", VERSION);
    //writefln("arch=%s build=%s config=%s", ARCH,BUILD,CONFIG);
    writefln("arch=%s build=%s", ARCH,BUILD);
    //writefln("debug=%s", DEBUGS.join(","));
}

@(TASK)
void prebuild() {
    deps(&banner);
    //exec("dub", ["fetch","gen-package-version"]);
    //exec("dub", ["fetch","vayne"]);
    //exec("dub", ["run","gen-package-version","--arch="~ARCH,"--build=release",
    //    "--", "dxx.tools","--root=.","--src=source"]);

    // project init templates
    exec("dub", ["run","vayne","--arch="~ARCH, "--",
      "resources/templates/init/plugin/dub.json",
      "resources/templates/init/plugin/plugin.def",
      "resources/templates/init/plugin/dale.d"
      ]);
}

@(TASK)
void test() {
    deps(&prebuild);
    exec("dub", ["test","--arch="~ARCH,"--build="~BUILD]);
    //string[] param;
    //param ~= "test";
    //foreach(p;PROJECTS) {
        //exec("dub", ["test","--arch="~ARCH,"--root="~p]);
        //exec("dub",["test","--arch="~ARCH,"--root="~p,"--build="~BUILD]);
    //}
}

void forcetest() {
    deps(&prebuild);
    exec("dub", ["test","--arch="~ARCH,"--force","--build="~BUILD]);
    //foreach(p;PROJECTS) {
    //    exec("dub", ["test","--arch="~ARCH,"--root="~p,"--force","--build="~BUILD]);
    //}
}

@(TASK)
void build() {
    deps(&prebuild);
    //deps(&test);
    exec("dub", [
        "build","--arch="~ARCH,"--build="~BUILD,"--config=dxx-tool-console"
    ]);
    //foreach(a;APPS) {
    //   exec("dub", ["build","--root="~a,"--arch="~ARCH,"--build="~BUILD]);
    //}
}

@(TASK)
void forcebuild() {
    deps(&clean);
    deps(&prebuild);
    deps(&forcetest);
    exec("dub", [
        "build","--root=.","--arch="~ARCH,"--force","--build="~BUILD,
        "--config=dxx-tool-console"
    ]);
}

@(TASK)
void update() {
    deps(&prebuild);
    exec("git", ["pull"]);
}

@(TASK)
void upgrade() {
    deps(&update);
    exec("dub", ["upgrade","--root=."]);
}

@(TASK)
void clean() {
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

@(TASK)
void run() {
    deps(&build);
    exec("dub",["run","--root=.","--arch="~ARCH,"--","init"]);
}

//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
