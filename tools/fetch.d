#!rdmd -I"scriptlike-0.10.2/scriptlike/src;source"

module tools.fetch;

private import std.stdio;
private import std.path;
private import std.getopt;
private import std.array;
private import scriptlike;

private import dxx.sys.appcmd;

void main(string[] args)
{
    tryRun(_git ~ " pull");
    tryRun(_rdmd ~ dmdopt ~ " tools/bootstrap.d");
}
