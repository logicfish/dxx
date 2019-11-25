private import dl;

private import dxx.packageVersion;
private import dxx.devconst;
private import dxx.constants;

private import ctini.ctini;

//private import scriptlike;

private import std.string;
private import std.array;
private import std.process;
private import std.conv;
private import std.file;
private import std.stdio;

private import std.experimental.logger;

enum CFG = IniConfig!("dale.ini");

immutable VERSION = packageVersion;


@(TASK)
void banner() {
    writefln("dxx %s", VERSION);
    //writefln("arch=%s build=%s config=%s", ARCH,BUILD,CONFIG);
    writefln("arch=%s build=%s", ARCH,BUILD);
    writefln("debug=%s", DEBUGS.join(","));
    sharedLog.info("nodeps=%s", NODEPS);
    sharedLog.info("force=%s", FORCE);
    sharedLog.info("args=%s", APPARG.join(" "));
    sharedLog.info("args passed=%s", ARGPASS.join(" "));
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
    deps(&build);
    foreach(a;APPS) {
      exec("dub", buildDubArgs!"build"(a));
    }
}

@(TASK)
void tool() {
    deps(&build);
    auto toolExec = runtimeConstants.appDir ~ "/../../../tool/";
    exec("dub",
        buildDubArgs!"build"(toolExec) ~ ["--config=dxx-tool-console"]
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
      //string[] arg = ARGS;
      chdir(toolExec);
      if(ARGPASS.length>0) {
        exec("bin/dxx", ARGPASS);
      } else {
        exec("bin/dxx", ["--help"]);
      }

}

@(TASK)
void update() {
    deps(&prebuild);
    exec("git", ["pull"]);
	deps(&upgrade);
}

@(TASK)
void upgrade() {
    deps(&prebuild);
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
    import std.file;
    "examples/basic".chdir;
    exec("bin/dxx-basic",["--age=10","--name='My Name'"]);
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
