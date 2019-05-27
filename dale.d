private import dl;

private import dxx.packageVersion;
private import dxx.devconst;
private import ctini.ctini;

//private import scriptlike;

private import std.file;
private import std.stdio;
private import std.string;
private import std.process;
private import std.conv;

enum CFG = IniConfig!("dale.ini");

immutable VERSION = packageVersion;


@(TASK)
void banner() {
    writefln("dxx %s", VERSION);
    //writefln("arch=%s build=%s config=%s", ARCH,BUILD,CONFIG);
    writefln("arch=%s build=%s", ARCH,BUILD);
    writefln("debug=%s", DEBUGS.join(","));
    writefln("nodeps=%s", NODEPS);
    writefln("force=%s", FORCE);
}

@(TASK)
void prebuild() {
    deps(&banner);
//        "dub run gen-package-version --arch=x86_64 -- dxx --root=$PACKAGE_DIR --src=source"
//    wait(execMut("dub", ["run","gen-package-version","--arch="~ARCH,"--build=release","--nodeps",
//      "--", "dxx","--root=.","--src=source"]).pid);
}

@(TASK)
void test() {
    deps(&prebuild);
    exec("dub", buildDubArgs!"test" ~ ["--config=dxx-lib"]);
    foreach(p;UTPROJECTS) {
        exec("dub",buildDubArgs!"test"(p));
    }
}

@(TASK)
void build() {
    deps(&prebuild);
    exec("dub", buildDubArgs!"build" ~ ["--config=dxx-lib"]);
    foreach(a;PROJECTS) {
       exec("dub", buildDubArgs!"build"(a));
    }
}

@(TASK)
void examples() {
    foreach(a;APPS) {
      exec("dub", buildDubArgs!"build"(a));
    }
}

@(TASK)
void tool() {
    deps(&build);
    exec("dub",
        buildDubArgs!"build"("tool") ~ ["--config=dxx-tool-console"]
    );
    /* exec("dub", ["build",
      "--root=tool",
      "--arch="~ARCH,
      "--build="~BUILD,
      "--config=dxx-tool-console"
      ]); */
      /* exec("dub", ["run",
        "dale",
        "--root=tool",
        "--arch="~ARCH,
        "--build="~BUILD
        ]); */
      //exec("tool/bin/dxx", ["--help"]);
}

@(TASK)
void _dxx() {
  auto args = buildDubArgs!("run");
  args ~= [ "--root=/e/workspaces/dxxworkspace/dxx/tool",
    "--config=dxx-tool-console" ];
  exec("dub",args);
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
    foreach(p;PROJECTS~APPS) {
        exec("dub", ["upgrade","--root="~p]);
    }
    exec("dub", ["upgrade","--root=tool"]);
}

@(TASK)
void boot() {
  deps(&upgrade);
  deps(&build);
}

@(TASK)
void clean() {
  foreach(p;PROJECTS~APPS) {
      exec("dub", ["clean","--root="~p]);
  }
  //exec("dub", ["clean","--root=."]);
}

/** Generate documentation */
@(TASK)
void doc() {
//    exec("doxygen");
    //tryExec("dub", ["fetch","ddox"]);
    foreach(p;PROJECTS) {
        execStatus("dub", ["build","-b=ddox","--root="~p,"--arch="~ARCH]);
    }
    execStatus("dub", ["build","-b=ddox","--root=.","--arch="~ARCH]);
    execStatus("dub", ["run","ddox","--arch="~ARCH,"--",
        "filter","./docs.json",
        "--ex","aermicioi",
        "--ex","ctini",
        "--ex","pegged",
        "--ex","properd"
      ]);
      execStatus("dub", ["run","ddox","--arch="~ARCH,"--",
        "generate-html","./docs.json","doc"
      ]);
}

/** Run D-Scanner */
@(TASK)
void dscanner() {
    exec("dub",["run","--arch="~ARCH,"--force","dscanner",
    "--","-S","source"]);
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
    auto cwd = getcwd().to!string;
    exec("dub", ["add-local", cwd]);
}

/** Uninstall artifacts */
@(TASK)
void uninstall() {
    auto cwd = getcwd().to!string;
    wait(execMut("dub", ["remove-local", cwd]).pid);
}

@(TASK)
void info() {
  exec("git", ["tag", "-l"]);
}

@(TASK)
void runexample() {
    deps(&examples);
    exec("examples/basic/bin/dxx-basic");
}

@(TASK)
void run() {
  deps(&tool);
    exec("tool/bin/dxx");
}

//@(TASK)
void push() {
  //exec("git","commit -m '<push>'");
  //exec("git push");
}

@(TASK)
void tag() {
  auto tag = __("build.tag");
  exec("git",["tag","-m",tag,"-a",tag]);
  exec("git",["push","--tags"]);
}

//@(TASK)
void bump() {
  exec("git tag -m '<tag>'");
}

//@(TASK)
void bumpminor() {
  exec("git tag -m '<tag>'");
}

//@(TASK)
void bumpmajor() {
  exec("git tag -m '<tag>'");
}

//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
