module scripts.appcmd;

private import std.path;

//version(Win64) {
version(Windows) {
  //version(WinPTY) {
    enum winpty = "winpty";
  //} else {
  //  enum winpty = "";
  //}
  enum dubopt = " --arch=x86_64 ";
  enum dmdopt = " -m64 ";
  enum _dub = winpty ~ " dub";
  enum _rdmd = "rdmd -Iscriptlike-0.10.2/scriptlike/src" ~ pathSeparator ~ "source";
  enum _git = winpty ~ " git";
} else {
    enum dubopt = "";
    enum dmdopt = "";
    enum _dub = "dub";
    enum _rdmd = "rdmd -Iscriptlike-0.10.2/scriptlike/src" ~ pathSeparator ~ "source";
    enum _git = "git";
}
