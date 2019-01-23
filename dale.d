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

template _(T) {
  auto _(string v) {
    return __c.locate!T(v);
  }
}

auto __(string v) {
  return _!string(v);
}
auto ___(string v) {
  return _!(string[])(v);
}

template APPS() {
  alias APPS=()=>___("build.apps");
}

template PROJECTS() {
  alias PROJECTS=()=>___("build.projects");
}

/* template UTAPPS() {
  auto UTAPPS() { return __c.locate!(string[])("ut.apps"); }
}*/

template UTPROJECTS() {
  alias UTPROJECTS=()=>___("ut.projects");
}
/*template UTDEBUGS() {
  auto UTDEBUGS() { return __c.locate!(string[])("ut.debug"); }
}
template UTCONFIG() {
  auto UTCONFIG() { return __c.locate!string("ut.config"); }
}*/

template ARCH() {
  alias ARCH=()=>__("build.arch");
}
template BUILD() {
  alias BUILD=()=>__("build.build");
}
template DEBUGS() {
  alias DEBUGS=()=>___("build.debug");
}
/*template CONFIG() {
  alias CONFIG=()=>__("build.config");
}*/
template FORCE() {
  alias FORCE=()=>__("build.force");
}


string[] buildDubArgs(string cmd)(string root=".") {
  string[] args;
  args ~= [
    cmd,
    "--arch="~ARCH,
    "--build="~BUILD,
    //"--config="~CONFIG,
    "--force="~FORCE,
    "--root="~root
  ];
  return args;
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
      exec("tool/bin/dxx", ["--help"]);
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
    exec("dub", ["fetch","ddox"]);
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
    exec("tool/bin/dxx");
}

//@(TASK)
void push() {
  exec("git commit -m '<push>'");
  exec("git push");
}

//@(TASK)
void tag() {
  auto tag = __c.locate!string("build.tag");
  exec("git tag -m "~tag~" -a "~tag);
  exec("git push --tags");
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
