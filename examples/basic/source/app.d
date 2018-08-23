module app;

private import aermicioi.aedi;

private import std.stdio;

private import dxx.app;
private import dxx.util;

enum CFG = DXXConfig ~ IniConfig!"basic.ini";

mixin __Text!(CFG.basic.lang);

class Example {
};

@component
class BasicModule : RuntimeModule {
    override void registerAppDependencies(DefaultInjector injector) {
    }
};

void main() {
    auto m = new BasicModule;
	MsgLog.info(MsgText!(CFG.basicMessages.MSG_APP_BANNER));
}
