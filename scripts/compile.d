#!/usr/bin/env dub
/+ dub.sdl:
	name "compile"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~master"
+/
module compile;

private import std.stdio;
private import std.path;
private import std.getopt;
private import std.experimental.logger;

private import scriptlike;
private import dxx.sys.appcmd;

enum projectPath = ".";
enum versionFile = "source/dxx/packageVersion.d";

void main(string[] args) {
    bool run = false;
    bool test = false;
    bool force = false;

    getopt(args,"r","Run examples",&run,
            "t","Test",&test,
            "f","Force build",&force
	  );
    string opt = dubopt;
    if(force) {
      opt ~= " -f";
      Path(versionFile).tryRemove;
    }
    version(Windows) {
      sharedLog.info("Building default lib for windows.");
      Path(projectPath).run(_dub ~ " build " ~ opt);
      Path(projectPath).run(_dub ~ " build :services " ~ opt);
    } else {
      sharedLog.info("Building default lib.");
      Path(projectPath).run("build");
    }
    if(test) {
      sharedLog.info("unittest");
      Path(projectPath).run(_dub ~ " test " ~ opt);
      Path(projectPath).run(_dub ~ " test :services " ~ opt);
			Path(projectPath).run(_dub ~ " test :tool " ~ opt);
    }
    if(run) {
      sharedLog.info("run");
      Path(projectPath).run(_dub ~ " run :basic " ~ opt);
    }
}
