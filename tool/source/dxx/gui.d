/**
Copyright 2018 Mark Fisher

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
**/
module dxx.gui;

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
    void registerTool(alias Cmd : string,T : Tool)(InjectionContainer injector) {
        injector.container.configure.register!Tool(new T,"tool.cmd."~Cmd);
    }
    override void registerAppDependencies(InjectionContainer injector) {
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
        defaultGetoptPrinter(ToolConfig.tools.applicationName,
            rslt.options);
        return -1;
    }
    string cmd = args[1];
    MsgLog.info("cmd = "~cmd);

    Tool tool;
    try {
        tool = resolveInjector!Tool("tool.cmd."~cmd);
    } catch(Exception e) {
        MsgLog.fatal(MsgText!(ToolConfig.toolsMessages.ERR_TOOL_NOT_FOUND)(cmd));
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

