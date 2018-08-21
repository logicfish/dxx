module app;

private import aermicioi.aedi;
private import std.stdio;
private import dxx.app;

class Example {
};

@component
class BasicModule : RuntimeModule {

};

void main() {
    auto m = new BasicModule;
	MsgLog.info("Edit source/app.d to start your project.");
}
