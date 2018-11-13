#!/usr/bin/env dub
/+ dub.sdl:
	name "tag"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~>0.0.9"
+/
module push;

private import std.stdio;
private import std.path;
private import std.getopt;
private import scriptlike;

private import dxx.sys.shellcmd;

enum projectPath = ".";

void main(string[] args) {
}
