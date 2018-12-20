import dl;

immutable VERSION = "0.0.1";

import std.stdio;

@(TASK)
void banner() {
    writefln("arithmancy %s", VERSION);
}

@(TASK)
void test() {
//    exec("dub", ["test","--arch=x86_64"]);
    exec("dub", ["test","--arch=x86_64","--root=core"]);
    exec("dub", ["test","--arch=x86_64","--root=app"]);
}

@(TASK)
void build() {
    deps(&test);
    exec("dub", ["build","--root=tool","--arch=x86_64"]);
    exec("dub", ["build","--root=examples/basic","--arch=x86_64"]);
    exec("dub", ["build","--root=examples/plugin","--arch=x86_64"]);
}

@(TASK)
void clean() {
    exec("dub", ["clean"]);
}

//@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
