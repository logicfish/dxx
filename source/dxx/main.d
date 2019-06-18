module dxx.main;

//private import dl;
private import std.file;
private import std.stdio;
private import std.string;
private import std.process;
private import std.conv;

private import dxx.constants;

version(DXX_App) {
  int main(string[] args) {
    version(Windows) {
      auto toolPath = runtimeConstants.appDir ~ "/../tool/bin/dxx.exe";
    } else {
      auto toolPath = runtimeConstants.appDir ~ "/../tool/bin/dxx";
    }
//    return execStatus(toolPath,args);
    writeln(toolPath);
    return 0;
  }
}
