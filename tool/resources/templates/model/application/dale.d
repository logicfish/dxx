import dl;

private import std.file;
private import std.stdio;
private import std.string;
private import std.process;

private import dxx;
private import dxx.core;

private import dxx.util;

private import dxx.app;
private import dxx.app.platform;
private import dxx.app.devprops;
//private import dxx.app.properties;
private import dxx.app.vaynetmplt;

private import dxx.{{vars.appid}}.packageVersion;

private import gen.dxxtool.autogen;

private import dxx.devconst;
private import ctini.ctini;


// Compile-time config
enum DaleConfig = DXXConfig ~ IniConfig!("{{app.ID}}-dale.ini");

alias {{app.appName}}DevParam = Tuple!(
  Tuple!(
    //string[],"projects",
    //string[],"apps",
    string[],"debugs",
    string,"buildType",
    string,"arch",
    string,"config",
    string,"force",
    string,"nodeps"
  ), "build",
  Tuple!(
    string[],"vayneDirs"
  ),"generate"
);

@component
class {{app.ID}}DevModule : PlatformRuntime!({{app.ID}}DevParam) {
  mixin __Text!(DaleConfig.build.lang);
  mixin registerComponent!({{app.ID}}DevModule);
}

immutable VERSION = packageVersion;

@(TASK)
void banner() {
    MsgLog.info("{{app.appName}} ", VERSION);
    writefln("arch=%s build=%s config=%s", ARCH,BUILD,CONFIG);
    //MsgLog.info("arch=%s build=%s", ARCH,BUILD);
    writefln("debug=%s", DEBUGS.join(","));
    writefln("nodeps=%s", NODEPS);
    writefln("force=%s", FORCE);
    //string vDirs = VAYNEDIRS.join(",");
    //writefln("build.vayneDirs=%s", vDirs);
}

@(TASK)
void prebuild() {
    deps(&banner);
//    deps(&generate);
}

@(TASK)
void test() {
    deps(&prebuild);
    exec("dub", buildDubArgs!"test" ~ ["--config="~CONFIG]);
    foreach(p;UTPROJECTS) {
        exec("dub",buildDubArgs!"test"(p));
    }
}

@(TASK)
void build() {
    deps(&prebuild);
    //deps(&test);
    //exec("dub", [
    //    "build","--arch="~ARCH,"--build="~BUILD,"--config="~CONFIG,"--nodeps="~NODEPS,"--force="~FORCE
    //]);
    //foreach(a;APPS) {
    //   exec("dub", ["build","--root="~a,"--arch="~ARCH,"--build="~BUILD]);
    //}
    exec("dub", buildDubArgs!"build" ~ ["--config="~CONFIG]);
    foreach(a;PROJECTS) {
       exec("dub", buildDubArgs!"build"(a));
    }
}

@(TASK)
void update() {
    deps(&prebuild);
//    exec("git", ["pull"]);
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
  foreach(p;PROJECTS) {
      execStatus("dub", buildDubArgs!"build"(p)~["-b=ddox"]);
  }
  execStatus("dub", buildDubArgs!"build"(".")~["-b=ddox"]);
  execStatus("dub", buildDubArgs!"run"(".")~["ddox", "--",
    "filter","./docs.json",
    "--ex","aermicioi",
    "--ex","ctini",
    "--ex","pegged",
    "--ex","properd"
  ]);
  execStatus("dub", buildDubArgs!"run"(".")~["ddox", "--",
    "generate-html","./docs.json","doc"
  ]);
}

/** Run D-Scanner */
@(TASK)
void dscanner() {
    execStatus("dub", buildDubArgs!"run"(".")~["dscanner", "--",
      "-S","source"
    ]);
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
    exec("dub", ["add-local", CWD]);
}

/** Uninstall artifacts */
@(TASK)
void uninstall() {
    auto cwd = getcwd();
    wait(execMut("dub", ["remove-local", CWD]).pid);
}

@(TASK)
void run() {
    deps(&build);
    exec("dub",["run","--root=.","--arch="~ARCH,"--","{{app.runArgs}}"]);
}

//@(TASK)
void main(string[] args) {
    phony([&clean,&banner,&prebuild]);
    mixin(yyyup!("args", "run"));
}
