#!rdmd -I"scriptlike-0.10.2/scriptlike/src"

module dxx.sys.tools.bootstrap;

private import std.stdio;
private import std.path;
private import scriptlike;

private import dxx.sys.appcmd;

enum projectPath = ".";
enum reggaeTarget = "binary";

void main() {
    tryRun("git pull");
    Path(projectPath ~ "/dub.selections.json").tryRemove;
    Path(projectPath).tryRun(_dub ~ " upgrade");
    tryRun(_dub ~ " fetch gen-package-version");
    tryRun(_dub~ " run gen-package-version "  ~ dubopt ~ " -- --src="~projectPath~"/source nox");
    version(Posix)enum buildExe = "build";
    version(Windows)enum buildExe = "build.exe";
    Path(projectPath ~ "/" ~ buildExe).tryRemove();
    Path(projectPath).tryRun(_dub ~ " run reggae " ~ dubopt ~ " -- -b "~reggaeTarget);
    //tryRun(_rdmd ~ dmdopt ~ " ./generate.d");
}

