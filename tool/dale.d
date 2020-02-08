import dl;

private import aermicioi.aedi;
private import ctini.ctini;

private import std.file;
private import std.path;
private import std.conv;
private import std.stdio;
private import std.string;
private import std.process;
private import std.array;

private import dxx.util;

private import dxx.app;
private import dxx.app.platform;
private import dxx.app.devprops;
//private import dxx.app.properties;
private import dxx.app.vaynetmplt;

private import dxx.tools.packageVersion;

// Compile-time config
enum DaleConfig = DXXConfig ~ IniConfig!("dale.ini");

alias ToolsDevParam = Tuple!(
  Tuple!(
    //string[],"projects",
    //string[],"apps",
    string[],"debugs",
    string,"buildType",
    string,"arch",
    string,"config",
    bool,"force",
    bool,"nodeps",
    bool,"parallel"
  ), "build",
  Tuple!(
    string[],"vayneDirs"
  ),"generate"
);

@component
class ToolsDevModule : PlatformRuntime!(ToolsDevParam) {
  mixin __Text!(DaleConfig.build.lang);
  mixin registerComponent!(ToolsDevModule);
}

immutable VERSION = packageVersion;



template VAYNEDIRS() {
  alias VAYNEDIRS=()=>Properties.___("generate.vayneDirs");
}
template TOOLDIR() {
  alias TOOLDIR=()=>APPDIR ~ "/..";
}



@(TASK)
void banner() {
    MsgLog.info("dxx tool ", VERSION);
    MsgLog.info("nodeps=", NODEPS.to!string);
    MsgLog.info("force=", FORCE.to!string);
    MsgLog.info("parallel=", PARALLEL.to!string);
    //MsgLog.info("args=", APPARG.join(" "));
    //MsgLog.info("args passed=", ARGPASS.join(" "));
}

@(TASK)
void prebuild() {
    deps(&banner);
    deps(&generate);
    /*if(!NODEPS) {
      tryExec("dub", ["fetch","gen-package-version"]);
      tryExec("dub", ["fetch","vayne"]);
    }*/
    //exec("dub", ["run","gen-package-version","--arch="~ARCH,"--build=release","--nodeps"
    //    "--", "dxx.tools","--root=.","--src=source"]);
}
@(TASK)
void generate() {
    //deps(&pregenerate);

    // loop through each file and run vayne...

    string[] vaynePaths;
    string[] templateFiles;
    foreach(vayneDir;VAYNEDIRS) {
      if(!vayneDir.exists) {
        MsgLog.warning("Not found " ~ vayneDir);
        continue;
      }
      if(!vayneDir.isDir) {
        vaynePaths ~= vayneDir;
        templateFiles ~= vayneDir~".vayne";
        continue;
      }
      foreach(e;vayneDir.dirEntries(SpanMode.breadth)) {
        if(!e.isDir && e.extension != ".vayne") {
          vaynePaths ~= e;
          templateFiles ~= e~".vayne";
        }
      }
    }
    string[] dubArgs = [
      "run","vayne","--arch="~ARCH, "--", "-j","resources"
    ];
    exec("dub",dubArgs ~ vaynePaths);

    // now create generator functions for each vayneDir entry
    //Path("source/gen/").mkdirRecurse;

    enum appID = DaleConfig.appVars.app.ID;
    enum srcGenDir = "source/gen/"~appID;
    enum autoGenFile = srcGenDir~"/autogen.d";

    writeln("APPID: "~appID);
    //srcGenDir.rmdir;
    srcGenDir.mkdirRecurse;

    struct Generator {
        string id;
        string[string] templates;
    }

    struct Vars {
        string appid = appID;
        Generator[string] generators;
    }
    static Vars vars;

    static string _id;
    void processGenerators(alias fields)() {
        static void __f(string fqn,string k,alias v)() {
            writeln(k ~ " == " ~ v.to!string ~ " : " ~ fqn);
            static if (k == "id") {
              MsgLog.info("Generator "~v);
              _id = v;
            }
            static if (k == "dir") {
              MsgLog.info("Generator dir "~v);
              string[string] templates;
              void process_dir(string dir) {
                foreach(string e;dir.dirEntries(SpanMode.depth)) {
                  if(e.isDir) {
                    MsgLog.info("Generator subdir "~e);
                    process_dir(e);
                  } else if(e.extension == ".vayne") {
                    //auto templ =
                    //    Tuple!(string,"name",string,"outFile")
                    //      (v,e.stripExt);
                    version(Windows) {
                      e = e.buildNormalizedPath.replace("\\","/");
                      //o = o.buildNormalizedPath.replace("\\","/");
                    } else {
                      e = e.buildNormalizedPath;
                      //o = o.buildNormalizedPath;
                    }
                    string o = e.chompPrefix(v~"/").stripExtension;
                    //templates[e]=e.stripExtension;
                    templates[e]=o;
                    MsgLog.trace("Template "~_id~ " " ~v~" "~e);
                  }
                }
              }
              process_dir(v);
              vars.generators[_id] = Generator(_id,templates);
            }
        }
        iterateValues!(fields,__f,"generators")();
    }

    processGenerators!(DaleConfig.generators)();
    renderVayneToFile!(DaleConfig.build.autogenTemplate,vars)(autoGenFile);
}

@(TASK)
void test() {
    deps(&prebuild);
    //exec("dub", ["test","--arch="~ARCH,"--build="~BUILD,"--nodeps="~NODEPS]);
    //string[] param;
    //param ~= "test";
    //foreach(p;PROJECTS) {
        //exec("dub", ["test","--arch="~ARCH,"--root="~p]);
        //exec("dub",["test","--arch="~ARCH,"--root="~p,"--build="~BUILD]);
    //}
    exec("dub",buildDubArgs!("test")~["--config="~CONFIG]);
}

void forcetest() {
    deps(&prebuild);
    exec("dub", ["test","--arch="~ARCH,"--force","--build="~BUILD,"--nodeps="~NODEPS]);
    //foreach(p;PROJECTS) {
    //    exec("dub", ["test","--arch="~ARCH,"--root="~p,"--force","--build="~BUILD]);
    //}
}

@(TASK)
void build() {
    deps(&prebuild);
    exec("dub",buildDubArgs!("build")~["--config="~CONFIG]);
}

@(TASK)
void forcebuild() {
    deps(&clean);
    deps(&prebuild);
    deps(&forcetest);
    exec("dub", [
        "build","--root=.","--arch="~ARCH,"--force","--build="~BUILD,"--nodeps="~NODEPS,
        "--config="~CONFIG
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
  execStatus("dub", [ "build","-b=ddox","--force","--arch="~ARCH,"--config="~CONFIG]);
  execStatus("dub", [ "run", "ddox", "--arch="~ARCH, "--",
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
    //exec("dub",["run","--root=.","--arch="~ARCH,"--","init"]);
    exec("dub", [
        "run","--root=.","--arch="~ARCH,
        "--nodeps=true", "--force=false",
        "--config=dxx-tool-console"
    ]);
//    exec("dub",
//      buildDubArgs!"run"(".") ~
//      [ "--" ] ~
//      runtimeConstants.argsAppPassthrough);
    //exec("");
}

//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "run"));
}
