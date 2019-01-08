private import dl;

private import std.file;
private import std.stdio;
private import std.string;
private import std.process;

private import dxx.packageVersion;
private import ctini.ctini;

private import aermicioi.aedi;
private import aermicioi.aedi_property_reader;

enum CFG = IniConfig!("dale.ini");

immutable VERSION = packageVersion;

//immutable PROJECTS = CFG.build.projects.split(',');
//immutable UT_PROJECTS = CFG.build.projects.split(',');
//immutable APPS = CFG.build.apps.split(',');

//immutable ARCH = CFG.build.arch;
//immutable DEBUGS = CFG.build.debugs;
//immutable CONFIG = CFG.build.config;
//immutable BUILD = CFG.build.build;

template __lookup(T,string v) {
  auto __lookup() {
    return __c.locate!T(v);
  }
}

template APPS() {
  auto APPS() { return __c.locate!(string[])("build.apps"); }
}

template PROJECTS() {
  auto PROJECTS() { return __c.locate!(string[])("build.projects"); }
}

//template UTAPPS() {
//  auto UTAPPS() { return __c.locate!(string[])("ut.apps"); }
//}

template UTPROJECTS() {
  auto UTPROJECTS() { return __c.locate!(string[])("ut.projects"); }
}

template ARCH() {
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
}
template UTDEBUGS() {
  auto UTDEBUGS() { return __c.locate!(string[])("ut.debug"); }
}
template CONFIG() {
  auto UTCONFIG() { return __c.locate!string("ut.config"); }
}



auto buildParam(string p) {

}

@(TASK)
void banner() {
    writefln("dxx %s", VERSION);
    //writefln("arch=%s build=%s config=%s", ARCH,BUILD,CONFIG);
    writefln("arch=%s build=%s", ARCH,BUILD);
    writefln("debug=%s", DEBUGS.join(","));
}

@(TASK)
void prebuild() {
    deps(&banner);
    exec("dub", ["fetch","gen-package-version"]);
    //exec("dub", ["fetch","vayne"]);
}

@(TASK)
void test() {
    deps(&prebuild);
    exec("dub", ["test","--arch="~ARCH,"--build="~BUILD]);
    string[] param;
    param ~= "test";
    foreach(p;UTPROJECTS) {
        //exec("dub", ["test","--arch="~ARCH,"--root="~p]);
        exec("dub",["test","--arch="~ARCH,"--root="~p,"--build="~BUILD]);
    }
}

void forcetest() {
    deps(&prebuild);
    exec("dub", ["test","--arch="~ARCH,"--force","--build="~BUILD]);
    foreach(p;UTPROJECTS) {
        exec("dub", ["test","--arch="~ARCH,"--root="~p,"--force","--build="~BUILD]);
    }
}

@(TASK)
void build() {
    deps(&prebuild);
    exec("dub", ["build","--arch="~ARCH,"--build="~BUILD,"--config=dxx-lib"]);
    foreach(a;PROJECTS) {
       exec("dub", ["build","--root="~a,"--arch="~ARCH,"--build="~BUILD]);
    }
}

@(TASK)
void examples() {
    foreach(a;APPS) {
       exec("dub", ["build","--root="~a,"--arch="~ARCH,"--build="~BUILD]);
    }
}

@(TASK)
void tool() {
    deps(&build);
    exec("dub", ["build",
      "--root=tool",
      "--arch="~ARCH,
      "--build="~BUILD,
      "--config=dxx-tool-console"
      ]);
      /* exec("dub", ["run",
        "dale",
        "--root=tool",
        "--arch="~ARCH,
        "--build="~BUILD
        ]); */
      exec("tool/bin/dxx", ["init"]);
}

@(TASK)
void forcebuild() {
    deps(&clean);
    deps(&prebuild);
    exec("dub", ["build","--arch="~ARCH,"--build="~BUILD]);
    foreach(a;PROJECTS) {
       exec("dub", ["test","--root="~a,"--arch="~ARCH,"--force","--build="~BUILD]);
       exec("dub", ["build","--root="~a,"--arch="~ARCH,"--force","--build="~BUILD]);
    }
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
    deps(&examples);
    exec("examples/basic/bin/dxx-basic");
}

//@(TASK)
void push() {
  exec("git commit -m '<push>'");
  exec("git push");
}

//@(TASK)
void tag() {
  exec("git tag -m '<tag>'");
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

void load(T : DocumentContainer!X, X...)(T container) {
	with (container.configure) { // Create a configuration context for config container
		register!string("build.arch"); // Define `protocol` property of type `string`
		register!string("build.build");
		//register!string("resource");
		//register!ushort("port");
		//register!(string[string])("arguments"); // Define `arguments` property of type `string[string]`
		//register!(size_t[])("nope-an-array");
    register!(string[])("build.debug");
    register!(string)("build.config");
    register!(string[])("build.projects");
    register!(string[])("build.apps");
    //register!Component("");
    //register!Component("json");
    register!string("ut.arch"); // Define `protocol` property of type `string`
		register!string("ut.build");
    register!(string[])("ut.debug");
    register!(string)("ut.config");
    register!(string[])("ut.projects");
    //register!(string[])("ut.apps");
	}
}

static Container __c;

//@(TASK)
void main(string[] args) {
    auto c = container(
      //singleton,
      //prototype,
      argument,
      env,
      //xml("config.xml"),
      json("resources/dale.json"),
      json("resources/dale-default.json"),
      //yaml("config.yaml"),
      //sdlang("config.sdlang")
    );

	  foreach (subcontainer; c) {
		    subcontainer.load;
    }
    __c = c;

    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
