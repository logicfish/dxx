#!/usr/bin/env dub
/+ dub.sdl:
	name "bootstrap"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~master"
+/
module bootstrap;

private import std.stdio;
private import std.path;
private import std.getopt;
private import scriptlike;

private import dxx.sys.appcmd;

enum projectPath = ".";
enum reggaeTarget = "binary";

enum upgradePaths = [ projectPath,"services","tool","examples/basic" ];

void main() {
    //tryRun("git pull");
    //Path(projectPath ~ "/dub.selections.json").tryRemove;
    //Path(projectPath).tryRun(_dub ~ " upgrade");
    upgradePaths.each!(a=>Path(a ~ "/dub.selections.json").tryRemove);
    upgradePaths.each!(a=>Path(a).tryRun(_dub ~ " upgrade"));
    tryRun(_dub ~ " fetch gen-package-version");
    tryRun(_dub~ " run gen-package-version "  ~ dubopt ~ " -- --src="~projectPath~"/source dxx");
    version(Posix)enum buildExe = "build";
    version(Windows)enum buildExe = "build.exe";
    Path(projectPath ~ "/" ~ buildExe).tryRemove();
    Path(projectPath).tryRun(_dub ~ " run reggae " ~ dubopt ~ " -- -b "~reggaeTarget);
    //tryRun(_rdmd ~ dmdopt ~ " ./generate.d");
}
