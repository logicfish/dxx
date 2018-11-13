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
module dxx.tools.tool;

private import eph.args;

private import dxx.tools;
private import dxx.tool;
private import dxx.util.injector;

struct ToolOptions {
    string organisation;
    string projectName;
    string projectVersion;
    string symbolicName;
    string author;
    string license;
    string lang;
    string desc;
}

interface Tool : WorkflowElement {
    enum OK = 0;
    int run(WorkflowJob job);
    //Argument getArgument(string key);
}

void registerArgument(DefaultInjector i,Argument arg,string id) {
	i.register!Argument(arg,id);
}
Argument getArgument(DefaultInjector i,string id) {
	return i.resolve!Argument(id);
}

abstract class ToolBase : WorkflowElement, Tool {
    int status = OK;
    override void setup(WorkflowJob job) {
    }
    override void process(WorkflowJob job) {
        status = run(job);
    }
    override void terminate(WorkflowJob job) {
    }
	 
    override int run(WorkflowJob job) {
	    //auto argsParser = injector.lookup!ArgParser;
	    auto argsParser = registerDefaultArgs(job);
	    argsParser.parse(job.workflow.args);
	    return this.runTool(job);
    }
    
    ArgParser registerArguments(ArgParser parser,WorkflowJob job) {
    	return parser;
    }
	int runTool(WorkflowJob job);
    
    ArgParser registerDefaultArgs(WorkflowJob job) {
		auto parser = job.injector.resolve!ArgParser;
       	Argument defArg = new Argument().shortFlag('D').longFlag("def").requireParam();
    	job.injector.registerArgument(defArg,ToolConfig.args.define);
    	return registerArguments(parser.register(defArg),job);
    }
}
