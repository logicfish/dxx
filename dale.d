/**
Copyright: 2018 Mark Fisher

License:
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/
private import dl;

private import dxx.packageVersion;
private import dxx.devconst;
private import dxx.constants;

private import ctini.ctini;

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
    sharedLog.info("dxx ", VERSION);
    sharedLog.info("nodeps=", NODEPS.to!string);
    sharedLog.info("force=", FORCE.to!string);
    sharedLog.info("parallel=", PARALLEL.to!string);
    sharedLog.info("args=", APPARG.join(" "));
    sharedLog.info("args passed=", ARGPASS.join(" "));
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
    chdir(toolExec);

    exec("dub",
        buildDubArgs!"run"() ~ ["--config=shi_sha","--"] ~ ARGPASS
    );

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
    
    exec("dub",
        buildDubArgs!"upgrade"(".")
    );

    foreach(p;PROJECTS~APPS) {
        exec("dub",
            buildDubArgs!"upgrade"(p)
        );
    }
    
}

@(TASK)
void boot() {
  deps(&upgrade);
  deps(&build);
}

@(TASK)
void clean() {
  foreach(p;PROJECTS~APPS) {
      exec("dub",
          buildDubArgs!"clean"(p)
      );
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
        "--ex=aermicioi",
        "--ex=ctini",
        "--ex=pegged",
        "--ex=properd"
      ]);
      execStatus("dub", ["run","ddox","--arch="~ARCH,"--",
        "generate-html","./docs.json","docs"
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
/*
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
*/

void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
