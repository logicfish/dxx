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
    string,"force",
    string,"nodeps"
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
      "run","vayne","--arch="~ARCH, "--"
    ];
    /* exec("dub", [,
      //"resources/templates/init/plugin/dub.json",
      //"resources/templates/init/plugin/plugin.def",
      //"resources/templates/init/plugin/dale.d"
      ]); */
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

    //static Generator[string] generators;

    // for each vayneDir
    //Variant[string] vars;
    //vars["generators"] = generators;
    //vars["appid"] = ""~appID;
    //autogenVars["templateFiles"]=templateFiles;
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
              //Variant[string] gen;
              //Generator gen;
              //Variant[] templates;
              string[string] templates;
              foreach(string e;v.dirEntries(SpanMode.breadth)) {
                if(!e.isDir && e.extension == ".vayne") {
                  //auto templ =
                  //    Tuple!(string,"name",string,"outFile")
                  //      (v,e.stripExt);
                  //templates ~= Variant(templ);
                  //templates[v]=Path(e.stripExt).asNormalizedPath.replace('\\','/');
                  version(Windows) {
                    templates[v]=e.stripExtension.buildNormalizedPath.replace("\\","/");
                  } else {
                    templates[v]=e.stripExtension.buildNormalizedPath;
                  }
                  //MsgLog.info("Template "~_id~ " " ~v~" "~Path(e.stripExt).asNormalizedPath);
                }
              }
              //gen["id"] = id;
              //gen["templates"] = templates;
              //gen.id = id;
              //gen.templates = templates;
              vars.generators[_id] = Generator(_id,templates);
              //vars.generators[id] = gen;
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
    exec("dub", ["test","--arch="~ARCH,"--build="~BUILD,"--nodeps="~NODEPS]);
    //string[] param;
    //param ~= "test";
    //foreach(p;PROJECTS) {
        //exec("dub", ["test","--arch="~ARCH,"--root="~p]);
        //exec("dub",["test","--arch="~ARCH,"--root="~p,"--build="~BUILD]);
    //}
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
    //deps(&test);
    exec("dub", [
        "build","--arch="~ARCH,"--build="~BUILD,"--config="~CONFIG,"--nodeps="~NODEPS,"--force="~FORCE
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
    exec("dub",["run","--root=.","--arch="~ARCH,"--","init"]);
}

//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "run"));
}
