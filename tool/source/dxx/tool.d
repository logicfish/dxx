module dxx.tool;

private import aermicioi.aedi;

private import std.getopt;
private import std.conv;
private import std.experimental.logger;
private import std.meta;

private import dxx.util;
private import dxx.app;
private import dxx.tools;

// Compile-time config
enum ToolConfig = DXXConfig ~ IniConfig!("tool.ini");

mixin __Text!(ToolConfig.tools.lang);

@component
class ToolsModule : RuntimeModule {
    void registerTool(alias Cmd : string,T : Tool)(DefaultInjector injector) {
        injector.container.configure.register!Tool(new T,"tool.cmd."~Cmd);
    }
    override void registerAppDependencies(DefaultInjector injector) {
        //sharedLog.trace("ToolsModule registerAppDependencies()");
        registerTool!("init",InitTool)(injector);
        registerTool!("install",InstallTool)(injector);
        registerTool!("lang",LangTool)(injector);
        registerTool!("cfg",CfgTool)(injector);
    }

};

struct Options {
};

int main(string[] args) {
    auto m = new ToolsModule;
    MsgLog.info(ToolConfig.tools.applicationName);
    Options opt;
    auto rslt = getopt(args
    );
    if (rslt.helpWanted) {
        defaultGetoptPrinter(ToolConfig.tools.applicationName,
            rslt.options);
        return 0;
    }
    if(args.length < 2) {
        return -1;
    }
    string cmd = args[1];
    MsgLog.info("cmd = "~cmd);

    auto tool = resolveInjector!Tool("tool.cmd."~cmd);
    if(tool is null) {
        MsgLog.fatal("Tool %s not found.");
        return -1;
    }
    MsgLog.trace("tool "~typeid(typeof(tool)).to!string);

    WorkflowElement[] elements = [ tool ];
    elements[0] = tool;
    auto wf = new DefaultWorkflow(elements,args);
    
    WorkflowRunner runner = resolveInjector!WorkflowRunner;
    auto job = runner.createJob(wf);
    job.execute;
    
    return 0;
}
