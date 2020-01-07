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
module dxx.tool.tool;

private import ctini.ctini;
private import aermicioi.aedi;
private import eph.args;

private import std.getopt;
private import std.conv;
private import std.experimental.logger;
private import std.meta;
private import std.typecons;

private import dxx.util;
private import dxx.util.ini;
private import dxx.app;
private import dxx.tool;
private import dxx.tools;
private import dxx.app.platform;

mixin __Text!(ToolConfig.tools.lang);

alias ToolsParam = Tuple!(
  Tuple!(
    Tuple!(
      string,"interactive"
    ),"cons"
  ), "cmd",
  //Tuple!(
  //  string,"target"
  //), "init",
  Tuple!(
    string,"projectType",
    string[],"dependencies"
  ), "project",
  Tuple!(
    Tuple!(
      string[],"type",
      string[],"define"
    ), "args"
  ), "dxx"
);

interface ToolsModuleInterface {
  public ArgParser getArgParser();
}

@component
class ToolsModule : PlatformRuntime!(
  ToolsParam,ToolsModule
),ToolsModuleInterface {
    static void registerTool(alias Cmd : string,T : Tool)(InjectionContainer injector) {
        injector.register!T("tool.cmd."~Cmd);
    }
    override void registerPlatformDependencies(InjectionContainer injector) {
        debug {
            sharedLog.trace("ToolsModule registerPlatformDependencies()");
        }
        super.registerPlatformDependencies(injector);
        registerTool!("init",InitTool)(injector);
        registerTool!("install",InstallTool)(injector);
        registerTool!("lang",LangTool)(injector);
        registerTool!("cfg",ConfigTool)(injector);
        registerTool!("cons",ConsoleTool)(injector);
        registerTool!("work",WorkflowTool)(injector);

        //InitTool.registerArguments(injector);
        //InstallTool.registerArguments(injector);
        //LangTool.registerArguments(injector);
        //CfgTool.registerArguments(injector);
    }

    @component
    override ArgParser getArgParser() {
        debug {
          sharedLog.trace("Get Args Parser");
        }
        return new ArgParser;
    }
    mixin registerComponent!ToolsModule;
};


version (DXX_Developer) {
  // ...
} else {
  struct Options {
      string[] inFiles;
  };

  int main(string[] args) {
      MsgLog.info(ToolConfig.tools.applicationName);

      Options opt;
      auto rslt = getopt(args,
          std.getopt.config.passThrough,
          "infile|i", &opt.inFiles
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
      MsgLog.info("Command: ",cmd);

      //auto loader = new PluginLoader("examples/plugin/bin/dxx_example-plugin.dll");
      //loader.update;

      Tool tool;
      try {
          tool = resolveInjector!Tool("tool.cmd."~cmd);
      } catch(Exception e) {
          MsgLog.fatal(MsgText!(ToolConfig.toolsMessages.ERR_TOOL_NOT_FOUND)(cmd));
          return -1;
      }
      WorkflowElement[] elements = [ tool ];
      auto wf = new DefaultWorkflow(elements,args);

      WorkflowRunner runner = resolveInjector!WorkflowRunner;
      auto job = runner.createJob(wf);
      DXXPlatform.executeJob(job);

      return 0;
  }

}
