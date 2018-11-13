#!/usr/bin/env dub
/+ dub.sdl:
	name "tag"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~>0.0.9"
+/
module dxx.sys.tools.tag;

private import std.stdio;
private import std.path;
private import std.getopt;
private import scriptlike;

private import dxx.sys.shellcmd;

enum projectPath = ".";

void main(string[] args) {
    bool show = false;

    getopt(args,"s","Show tag",&show);

    if(show) {
        tryRun(_git ~ " describe");
        tryRun(_git ~ " status");
    } else if(args.length == 1) {
	    // show help...
	    writeln("Usage: tag.d <version>");
    } else {
        string versionString = args[1];
        tryRun(_git ~ " tag -a " ~ versionString ~ " -m 'Version " ~ versionString ~"'");
        tryRun(_git ~ " push --tags");
        tryRun("scripts/bootstrap.d");
    }
}
