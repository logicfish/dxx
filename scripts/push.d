#!/usr/bin/env dub
/+ dub.sdl:
	name "tag"
	dependency "scriptlike" version="~>0.10.2"
	dependency "dxx" version="~master"
+/
module push;

private import std.stdio;
private import std.path;
private import std.getopt;
private import scriptlike;

private import dxx.sys.appcmd;

enum projectPath = ".";

void main(string[] args) {
}