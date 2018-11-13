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
module dxx.app.component;

private import aermicioi.aedi;
private import eph.args;

private import core.runtime;

private import std.experimental.logger;

private import dxx.util.injector;
private import dxx.util.config;
private import dxx.app;

interface DXXComponents {
    //public RuntimeComponents getRuntimeComponents();
    public Logger getLogger();
    public ArgParser getArgParser();
    public WorkflowRunner getWorkflowRunner();
}

@component
abstract class RuntimeComponents : DXXComponents {
    static __gshared RuntimeComponents INSTANCE;

    static WorkflowRunner workflowRunner;
//    static ArgParser argParser;
    DefaultInjector _injector;

    //static __gshared ExtensionPointManager extensionPointManager;

    abstract void registerAppDependencies(DefaultInjector injector);

    public {
        //@component
        //override RuntimeModule getRuntimeComponents() {
        //    return INSTANCE;
        //}
        @component
        override Logger getLogger() {
            return sharedLog;
        }
        @component
        override ArgParser getArgParser() {
    //    	if(argParser is null) {
    //			argParser = new ArgParser;
    //			Parameter param = new Parameter();
    //			argParser.register(param);
    //			//string args = AppConfig.get(DXXConfig.keys.commandLine);
    //			//args.split(" ");
    //			//Argument[] arguments = resolveInjector!(Argument[])();
    //			//arguments.each!(a => argParser.register(a)); 
    //			
    ////			auto args = Runtime.args;
    ////			argParser.parse(args);
    //    	}
    //    	return argParser;
    		return new ArgParser;
        }

        @component
        override WorkflowRunner getWorkflowRunner() {
            if(workflowRunner is null) {
                workflowRunner = new WorkflowRunner;
            }
            return workflowRunner;
        }
    }

    
    nothrow
	static DefaultInjector injector() {
    	return INSTANCE._injector;
    }

    //@component
    //public ExtensionPointManager getExtensionPointManager() {
    //    if(extensionPointManager is null) {
    //        extensionPointManager = new ExtensionPointManager;
    //    }
    //    return extensionPointManager;
    //}

    public this(this T)() {
        if(INSTANCE is null) {
            INSTANCE = this;
            _injector = newInjector!T;
            registerAppDependencies(_injector);
            _injector.instantiate();
        }
    }
}