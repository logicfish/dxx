#!/usr/bin/env dub
/+ dub.sdl:
	name "fetch"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~>0.0.9"
+/
module fetch;

private import std.stdio;
private import std.path;
private import std.getopt;
private import scriptlike;

private import dxx.sys.shellcmd;

void main(string[] args)
{
    tryRun(_git ~ " pull");
    tryRun(_rdmd ~ dmdopt ~ " tools/bootstrap.d");
}
